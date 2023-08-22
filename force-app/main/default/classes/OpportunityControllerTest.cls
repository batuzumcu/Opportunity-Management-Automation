@isTest
private class OpportunityControllerTest {
    
    @testSetup
    static void setupTestData() {
        List<Opportunity> testOpps = new List<Opportunity>();
        for (Integer i = 0; i < 5; i++) {
            testOpps.add(new Opportunity(
                Name = 'Test Opportunity ' + i,
                StageName = 'Prospecting',  
                CloseDate = Date.today().addDays(30)
            ));
        }
        insert testOpps;
    }
    
    @isTest
    static void testGetOpportunities() {
        Test.startTest();
        List<Opportunity> opps = OpportunityController.getOpportunities();
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateOpportunityStatus() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity LIMIT 5];
        List<Id> oppIds = new List<Id>();
        for(Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }
        
        Test.startTest();
        OpportunityController.updateOpportunityStatus(oppIds, 'Closed Won');  
        Test.stopTest();
    }

    @isTest
    static void testUpdateOpportunityStatusWithBlankStatus() {
        List<Opportunity> opps = [SELECT Id FROM Opportunity LIMIT 5];
        List<Id> oppIds = new List<Id>();
        for(Opportunity opp : opps) {
            oppIds.add(opp.Id);
        }

        Test.startTest();
        OpportunityController.updateOpportunityStatus(oppIds, ''); 
        Test.stopTest();
    }

    @isTest
    static void testGetOpportunityStageNames() {
        Test.startTest();
        List<String> stages = OpportunityController.getOpportunityStageNames();
        Test.stopTest();
    }
}
