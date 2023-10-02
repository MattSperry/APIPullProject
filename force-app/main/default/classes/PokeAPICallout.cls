public without sharing class PokeAPICallout {
  @InvocableMethod(label='Pokemon API Call' description='Generates pokemon listed in the flow on the current Account')
  public static void makeGetCallout(List<PokemonData> pokemonDataList) {
    System.enqueueJob(new QueueablePokemonJob(pokemonDataList, 0, 0, 0));
  }
  // Create pokemon data
  public class PokemonData {
    @InvocableVariable(label='Number of Pokemon' required=true)
    public Integer numPokemon;
    @InvocableVariable(label='Account Id')
    public Id accountId;
  }
}
