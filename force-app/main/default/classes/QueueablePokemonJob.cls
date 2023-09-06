public class QueueablePokemonJob implements Queueable, Database.AllowsCallouts {
  private Id accountId;
  private Integer numPokemon;
  private Integer batchNum;
  public static final String POKE_URL = 'https://pokeapi.co/api/v2/pokemon?';

  public QueueablePokemonJob(Id accountId, Integer numPokemon, Integer batchNum) {
    this.accountId = accountId;
    this.numPokemon = numPokemon;
    this.batchNum = batchNum;
  }

  public void execute(QueueableContext context) {
    Http http = new Http();
    System.debug('numPokemon in queueable class: ' + numPokemon);
    System.debug('batchNum: ' + batchNum);
    // Create a list to store Pokemon
    List<Pokemon__c> pokemonList = new List<Pokemon__c>();

    // Get right number of pokemon
    Integer leftOverPokemon = math.mod(numPokemon, 5);
    Integer totalBatches = (Integer) Math.ceil((Decimal) numPokemon / 5);
    System.debug('leftOverPokemon: ' + leftOverPokemon);
    System.debug('totalBatches: ' + totalBatches);

    // Create GET request for all pokemon in list
    System.debug('Min of batch and pokemon: ' + Math.min(numPokemon, PokeAPICallout.batchSize));
    HttpRequest request = new HttpRequest();
    String pokemonUrl;
    // If it isn't the last batch get 5 pokemon
    if (totalBatches != batchNum + 1 || leftOverPokemon == 0) {
      pokemonUrl =
        POKE_URL +
        'limit=' +
        PokeAPICallout.batchSize +
        '&offset=' +
        PokeAPICallout.batchSize * batchNum +
        '/';
    } else {
      // Get left over pokemon on last batch
      pokemonUrl = POKE_URL + 'limit=' + leftOverPokemon + '&offset=' + PokeAPICallout.batchSize * batchNum + '/';
    }

    request.setEndpoint(pokemonUrl);
    request.setMethod('GET');
    HttpResponse response = http.send(request);

    // Debug for errors
    if (response.getStatusCode() != 200) {
      System.debug(
        'Error in API callout for pokemon with batch size ' +
          Math.min(numPokemon, PokeAPICallout.batchSize) +
          ': ' +
          response.getBody()
      );
      return;
    }

    // Get Json map
    PokeResponse results = (PokeResponse) JSON.deserialize(response.getBody(), PokeResponse.class);

    for (PokeResponse.Result result : results.results) {
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

      pokemonList.add(pokemon);
    }

    // Insert pokemon list
    if (pokemonList.size() > 0) {
      insert pokemonList;
      System.debug('Pokemon Entered: ' + pokemonList.size());
      System.debug('Pokemon List: ' + pokemonList);
    }
  }
}
