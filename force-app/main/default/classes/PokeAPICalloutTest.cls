@IsTest
private class PokeAPICalloutTest {
  @TestSetup
  static void makeData() {
    // Create test Account
    Account testAccount = new Account(Name = 'SOLVD');
    insert testAccount;
  }
  @IsTest
  static void testSuccessfulCallout() {
    // Get test account
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'SOLVD' LIMIT 1];
    // Create test data
    List<PokeAPICallout.PokemonData> testData = new List<PokeAPICallout.PokemonData>();
    PokeAPICallout.PokemonData testDataItem = new PokeAPICallout.PokemonData();
    testDataItem.numPokemon = 5;
    testDataItem.accountId = testAccount.Id;
    testData.add(testDataItem);

    // Set up mock callout response
    Test.setMock(HttpCalloutMock.class, new PokeAPICalloutMock(true));

    // Call the method to test
    Test.startTest();
    PokeAPICallout.makeGetCallout(testData);
    Test.stopTest();

    System.assertEquals(
      5,
      [SELECT COUNT() FROM Pokemon__c WHERE Account__c = :testAccount.Id],
      'Unexpected number of Pokemon records created.'
    );
  }

  @IsTest
  static void testFailedCallout() {
    // Get test account
    Account testAccount = [SELECT Id FROM Account WHERE Name = 'SOLVD' LIMIT 1];
    // Create test data
    List<PokeAPICallout.PokemonData> testData = new List<PokeAPICallout.PokemonData>();
    PokeAPICallout.PokemonData testDataItem = new PokeAPICallout.PokemonData();
    testDataItem.numPokemon = 5;
    testDataItem.accountId = testAccount.Id;
    testData.add(testDataItem);

    // Set up mock callout response
    Test.setMock(HttpCalloutMock.class, new PokeAPICalloutMock(false));

    // Call the method to test
    Test.startTest();
    PokeAPICallout.makeGetCallout(testData);
    Test.stopTest();

    System.assertEquals(
      0,
      [SELECT COUNT() FROM Pokemon__c WHERE Account__c = :testAccount.Id],
      'should not return a Pokemon object'
    );
  }
}
