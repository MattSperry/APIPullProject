@IsTest
private class PokeAPICalloutTest {
  @TestSetup
  static void makeData() {
    // Create test Account
    Account testAccount = new Account(Name = 'SOLVD');
    insert testAccount;
  }
  @IsTest
  static void testMakeGetCalloutSuccess() {
    // Create Pokemon Data
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'SOLVD' LIMIT 1];

    // Create Pokemon Data
    PokeAPICallout.PokemonData pokemonData = new PokeAPICallout.PokemonData();
    pokemonData.accountId = testAccount.Id;
    pokemonData.numPokemon = 10;
    List<PokeAPICallout.PokemonData> pokemonDataList = new List<PokeAPICallout.PokemonData>();
    pokemonDataList.add(pokemonData);

    // Run Test
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PokeAPICalloutMock(true));
    PokeAPICallout.makeGetCallout(pokemonDataList);
    Test.stopTest();

    // Verify results
    System.assertEquals(
      10,
      [SELECT COUNT() FROM Pokemon__c WHERE Account__c = :testAccount.Id],
      'should return 10 Pokemon objects'
    );
  }
  @IsTest
  static void testMakeGetCalloutFailure() {
    // Create Pokemon Data for a nonexistent Pokemon
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'SOLVD' LIMIT 1];

    PokeAPICallout.PokemonData pokemonData = new PokeAPICallout.PokemonData();
    pokemonData.accountId = testAccount.Id;
    pokemonData.numPokemon = 7;
    List<PokeAPICallout.PokemonData> pokemonDataList = new List<PokeAPICallout.PokemonData>();
    pokemonDataList.add(pokemonData);

    // Run Test
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PokeAPICalloutMock(false));
    PokeAPICallout.makeGetCallout(pokemonDataList);
    Test.stopTest();

    // Verify results
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Pokemon__c WHERE Account__c = :testAccount.Id],
      'should not return a Pokemon object'
    );
  }
}
