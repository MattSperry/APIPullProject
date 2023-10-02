public class QueueablePokemonJob implements Queueable, Database.AllowsCallouts {
  public static Integer batchSize = 5;
  private List<PokeAPICallout.PokemonData> pokemonDataList;
  public static final String POKE_URL = 'https://pokeapi.co/api/v2/pokemon?';
  private Integer batchNum;
  private Integer pokemonLeft;
  private static Integer numPokemon;
  private Integer batch;
  private static Id accountId;
  private List<Pokemon__c> pokemonList = new List<Pokemon__c>();

  public QueueablePokemonJob(
    List<PokeAPICallout.PokemonData> pokemonDataList,
    Integer pokemonLeft,
    Integer batchNum,
    Integer batch
  ) {
    this.pokemonDataList = pokemonDataList;
    this.pokemonLeft = pokemonLeft;
    this.batchNum = batchNum;
    this.batch = batch;
  }

  public void execute(QueueableContext context) {
    // loop through context
    // for the first batchSize # of records, place record into different list and remove from context (pokemonDataList)

    if (pokemonLeft == 0 && batchNum == 0) {
      if (!pokemonDataList.isEmpty()) {
        PokeAPICallout.PokemonData pokemonData = pokemonDataList[0]; // Get the first element
        numPokemon = pokemonData.numPokemon;
        accountId = pokemonData.accountId;
        batch = 0;
        batchNum = 0;
        pokemonLeft = numPokemon;
      }
    } else {
      if (!pokemonDataList.isEmpty()) {
        PokeAPICallout.PokemonData pokemonData = pokemonDataList[0];
        numPokemon = pokemondata.numPokemon;
        pokemonLeft = numPokemon - (batchSize * batchNum); // Reset pokemonLeft for the current batch
        accountId = pokemonData.accountId;
      }
    }

    for (Integer i = 0; i < Math.min(pokemonLeft, batchSize); i++) {
      batch += 1;
      System.debug('batch: ' + batch);
      if (batch >= batchSize || i == numPokemon - 1 || i == pokemonLeft - 1) {
        // Run logic
        Http http = new Http();
        System.debug('numPokemon in queueable class: ' + numPokemon);
        System.debug('batchNum: ' + batchNum);

        // Get right number of pokemon
        Integer leftOverPokemon = math.mod(numPokemon, 5);
        Integer totalBatches = (Integer) Math.ceil((Decimal) numPokemon / batchSize);
        System.debug('leftOverPokemon: ' + leftOverPokemon);
        System.debug('totalBatches: ' + totalBatches);

        // Create GET request for all pokemon in list
        System.debug('Min of batch and pokemon: ' + Math.min(numPokemon, batchSize));
        HttpRequest request = new HttpRequest();
        String pokemonUrl;
        // If it isn't the last batch get 5 pokemon
        if (totalBatches != batchNum + 1 || leftOverPokemon == 0) {
          system.debug('not last batch: total batches: ' + totalBatches + ' batch num: ' + batchNum);
          pokemonUrl = POKE_URL + 'limit=' + batchSize + '&offset=' + batchSize * batchNum + '/';
        } else {
          // Get left over pokemon on last batch
          system.debug('grabbed ' + leftOverPokemon + ' leftover pokemon');
          pokemonUrl = POKE_URL + 'limit=' + leftOverPokemon + '&offset=' + batchSize * batchNum + '/';
          system.debug('pokeURL: ' + pokemonUrl);
        }

        request.setEndpoint(pokemonUrl);
        request.setMethod('GET');
        HttpResponse response = http.send(request);

        // Debug for errors
        if (response.getStatusCode() != 200) {
          System.debug(
            'Error in API callout for pokemon with batch size ' +
              Math.min(numPokemon, batchSize) +
              ': ' +
              response.getBody()
          );
          return;
        }

        // Get Json map
        system.debug('Json map: ' + response.getBody());
        PokeResponse results = (PokeResponse) JSON.deserialize(response.getBody(), PokeResponse.class);

        for (PokeResponse.Result result : results.results) {
          system.debug('Assigning fields from API');
          // Get fields from api
          String name = (String) result.name;
          String url = (String) result.url;

          // Assign fields to pokemon records
          Pokemon__c pokemon = new Pokemon__c();
          // Get Id from URL
          String[] urlParts = url.split('/');
          String lastPart = urlParts[urlParts.size() - 1];
          pokemon.PokeId__c = Integer.valueOf(lastPart);
          pokemon.Name = name;
          pokemon.URL__c = url;
          pokemon.Account__c = accountId;
          system.debug(pokemon + ' added to list');

          pokemonList.add(pokemon);
        }

        batch = 0; // Reset the batch to 0 for next batch
        batchNum++; // Move to the next batch
        pokemonLeft -= batchSize;

        system.debug('pokemon left: ' + pokemonLeft);

        if (!pokemonList.isEmpty()) {
          System.debug('inserting');
          insert pokemonList;
          System.debug('Pokemon Entered: ' + pokemonList.size());
          System.debug('Pokemon List: ' + pokemonList);
          pokemonList.clear();
        }

        if (pokemonLeft > 0) {
          system.debug('reenqueuing');
          System.enqueueJob(new QueueablePokemonJob(pokemonDataList, pokemonLeft, batchNum, batch)); // enqueue the instance you're on
        }
      }
    }
    pokemonDataList.remove(0);

    if (pokemonDataList.isEmpty()) {
      return; // No more data, exit the job
    }

    // If there are more PokemonData objects, enqueue a new instance of QueueablePokemonJob
    PokeAPICallout.PokemonData nextPokemonData = pokemonDataList.remove(0);
    numPokemon = nextPokemonData.numPokemon;
    accountId = nextPokemonData.accountId;
    batchNum = 0;
    batch = 0;
    pokemonLeft = 0;

    // After inserting records, enqueue the next job separately
    System.enqueueJob(new QueueablePokemonJob(pokemonDataList, pokemonLeft, batchNum, batch)); // pass in the list minus 1 for each time the pokemonData is processed
  }
}
