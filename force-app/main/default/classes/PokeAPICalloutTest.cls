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
    Pokemon__c testPokemon = new Pokemon__c(Name = 'snorlax', Account__c = testAccount.Id);
    insert testPokemon;

    // Create Pokemon Data
    PokeAPICallout.PokemonData pokemonData = new PokeAPICallout.PokemonData();
    pokemonData.pokemonName = testPokemon.Name;
    pokemonData.accountId = testAccount.Id;
    List<PokeAPICallout.PokemonData> pokemonDataList = new List<PokeAPICallout.PokemonData>();
    pokemonDataList.add(pokemonData);

    // Run Test
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PokeAPICalloutMock());
    PokeAPICallout.makeGetCallout(pokemonDataList);
    Test.stopTest();

    // Verify results
    System.assertEquals(1, [SELECT COUNT() FROM Pokemon__c WHERE Name = 'snorlax'], 'should return 1 Pokemon object');
  }
  @IsTest
  static void testMakeGetCalloutFailure() {
    // Create Pokemon Data for a nonexistent Pokemon
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'SOLVD' LIMIT 1];

    PokeAPICallout.PokemonData pokemonData = new PokeAPICallout.PokemonData();
    pokemonData.pokemonName = 'nonexistent_pokemon'; // Simulate a nonexistent Pokemon
    pokemonData.accountId = testAccount.Id;
    List<PokeAPICallout.PokemonData> pokemonDataList = new List<PokeAPICallout.PokemonData>();
    pokemonDataList.add(pokemonData);

    // Run Test
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new PokeAPICalloutMock());
    PokeAPICallout.makeGetCallout(pokemonDataList);
    Test.stopTest();

    // Verify results
    System.assertEquals(
      0,
      [SELECT COUNT() FROM Pokemon__c WHERE Name = 'snorlax'],
      'should not return a Pokemon object'
    );
  }
}