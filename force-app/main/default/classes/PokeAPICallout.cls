public without sharing class PokeAPICallout {
  private static final String POKE_URL = 'https://pokeapi.co/api/v2/pokemon/';

  @InvocableMethod(label='Pokemon API Call')
  public static void makeGetCallout(List<PokemonData> pokemonDataList) {
    Http http = new Http();

    // Create a list to store Pokemon
    List<Pokemon__c> pokemonList = new List<Pokemon__c>();
    // Create GET request for all pokemon in list
    for (PokemonData pokemonData : pokemonDataList) {
      String pokemonName = pokemonData.pokemonName;
      HttpRequest request = new HttpRequest();
      String pokemonUrl = POKE_URL + pokemonName.toLowerCase() + '/';
      request.setEndpoint(pokemonUrl);
      request.setMethod('GET');
      HttpResponse response = http.send(request);

      // Debug for errors
      if (response.getStatusCode() != 200) {
        System.debug('Error in API callout for ' + pokemonName + ': ' + response.getBody());
        return;
      }
      // Get Json map
      Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

      // Get fields from api
      String name = (String) resultMap.get('name');
      Integer id = (Integer) resultMap.get('id');

      // Assign fields to pokemon records
      Pokemon__c pokemon = new Pokemon__c();
      pokemon.PokeId__c = id;
      pokemon.Name = name;
      pokemon.URL__c = pokemonUrl;
      pokemon.Account__c = pokemonData.accountId;

      pokemonList.add(pokemon);
    }
    // Insert pokemon list
    if (pokemonList.size() > 0) {
      insert pokemonList;
      System.debug('Pokemon Entered: ' + pokemonList.size());
      System.debug('Pokemon List: ' + pokemonList);
    }
  }
  // Create pokemon data
  public class PokemonData {
    @InvocableVariable(label='Pokemon Name' required=true)
    public String pokemonName;
    @InvocableVariable(label='Account Id')
    public Id accountId;
  }
}