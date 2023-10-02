@IsTest
global class PokeAPICalloutMock implements HttpCalloutMock {
  private Boolean simulateSuccess;

  global PokeAPICalloutMock(Boolean simulateSuccess) {
    this.simulateSuccess = simulateSuccess;
  }

  global HTTPResponse respond(HTTPRequest req) {
    HttpResponse response = new HttpResponse();
    response.setHeader('Content-Type', 'application/json');

    if (simulateSuccess) {
      // Simulate a successful response with a status code of 200
      response.setStatusCode(200);
      response.setBody(
        '{"results":[{"name":"snorlax", "Account__c":"SOLVD", "url":"https://pokeapi.co/api/v2/pokemon/143/"},' +
          '{"name":"articuon", "Account__c":"SOLVD", "url":"https://pokeapi.co/api/v2/pokemon/144/"},' +
          '{"name":"zapdos", "Account__c":"SOLVD", "url":"https://pokeapi.co/api/v2/pokemon/145/"},' +
          '{"name":"moltres", "Account__c":"SOLVD", "url":"https://pokeapi.co/api/v2/pokemon/146/"},' +
          '{"name":"dratini", "Account__c":"SOLVD", "url":"https://pokeapi.co/api/v2/pokemon/147/"}]}'
      );
    } else {
      // Simulate a failed response with a status code other than 200
      response.setStatusCode(400);
      response.setBody('{"error": "API call failed"}');
    }

    return response;
  }
}
