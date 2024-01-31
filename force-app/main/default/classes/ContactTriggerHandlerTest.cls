@isTest
private class ContactTriggerHandlerTest {

    @isTest
    static void testOnAfterUpdate() {
        // Create test data
        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            buildertek__Hourly_Rate__c = 20.0
        );
        insert testContact;

        buildertek__Time_Cards__c testTimeCard = new buildertek__Time_Cards__c(
            buildertek__Resource__c = testContact.Id
        );
        insert testTimeCard;

        // Update the contact to trigger the onAfterUpdate logic
        testContact.buildertek__Hourly_Rate__c = 25.0;
        update testContact;

    }
}