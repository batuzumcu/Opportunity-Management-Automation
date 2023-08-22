@isTest
private class OpportunitiesTriggerTest {
    
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
    static void testInsertClosedWonOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity Closed Won',
            StageName = 'Closed Won',
            CloseDate = Date.today().addDays(30)
        );

        Test.startTest();
        insert opp;
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateOpportunityToClosedWon() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Prospecting' LIMIT 1];
        
        opp.StageName = 'Closed Won';
        
        Test.startTest();
        update opp;
        Test.stopTest();
    }

    @isTest
    static void testNoTaskCreatedForOtherStages() {
        Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE StageName = 'Prospecting' LIMIT 1];

        opp.StageName = 'Qualification';  
        
        Test.startTest();
        update opp;
        Test.stopTest();
    }

    @isTest
    static void testClosedWonOpportunityWithPrimaryContact() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        Contact cont = new Contact(LastName = 'Doe', AccountId = acc.Id);
        insert cont;

        Opportunity opp = new Opportunity(
            Name = 'Opportunity with Primary Contact',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId = opp.Id, ContactId = cont.Id, IsPrimary = true);
        insert ocr;
        
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
    }

    @isTest
    static void testClosedWonOpportunityWithMultipleContacts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        List<Contact> contacts = new List<Contact> {
            new Contact(LastName = 'First', AccountId = acc.Id, CreatedDate = System.now()),
            new Contact(LastName = 'Last', AccountId = acc.Id, CreatedDate = System.now().addDays(-1))
        };
        insert contacts;

        Opportunity opp = new Opportunity(
            Name = 'Opportunity with Multiple Contacts',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;
        
        List<OpportunityContactRole> ocrList = new List<OpportunityContactRole> {
            new OpportunityContactRole(OpportunityId = opp.Id, ContactId = contacts[0].Id),
            new OpportunityContactRole(OpportunityId = opp.Id, ContactId = contacts[1].Id)
        };
        insert ocrList;
        
        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
    }
    
    @isTest
    static void testClosedWonOpportunityNoContactsAccountHasContacts() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];
        
        List<Contact> contacts = new List<Contact> {
            new Contact(LastName = 'A', AccountId = acc.Id, CreatedDate = System.now()),
            new Contact(LastName = 'B', AccountId = acc.Id, CreatedDate = System.now().addDays(-1))
        };
        insert contacts;

        Opportunity opp = new Opportunity(
            Name = 'Opportunity No Contacts',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            AccountId = acc.Id
        );
        insert opp;

        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();
    }
}
