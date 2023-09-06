public without sharing class PokeAPICallout {
  public static Integer batchSize = 5;
  @InvocableMethod(
    label='Pokemon API Call'
    description='Generates pokemon listed in the flow on the current Account'
    callout=true
  )
  public static void makeGetCallout(List<PokemonData> pokemonDataList) {
    for (PokemonData pokemonData : pokemonDataList) {
      Integer numPokemon = pokemonData.numPokemon;
      Id accountId = pokemonData.accountId;
      Integer batch = 0;
      Integer batchNum = 0;

      for (Integer i = 0; i < numPokemon; i++) {
        batch += 1;
        System.debug('batch: ' + batch);
        if (batch >= batchSize || i == numPokemon - 1) {
          System.enqueueJob(new QueueablePokemonJob(accountId, numPokemon, batchNum));
          batch = 0;
          batchNum += 1;
        }
      }
    }
  }
  // Create pokemon data
  public class PokemonData {
    @InvocableVariable(label='Number of Pokemon' required=true)
    public Integer numPokemon;
    @InvocableVariable(label='Account Id')
    public Id accountId;
  }
}
