@IsTest(SeeAllData=true)
public with sharing class InSiteEnquiryUtilsTest {



	@IsTest(SeeAllData=true)
	public static void testByEmail() {
		Contact testContact = new Contact(Salutation='Mr', FirstName='Test', LastName='Person', Email='test.person@email.com', MobilePhone='0400000000', LeadSource='Project Website');
		insert testContact;

		pba__Property__c testProject = new pba__Property__c(RecordTypeId='0122w000001HieuAAC', Name='Test Project');
		insert testProject;

		Id contactId = Id.valueOf(testContact.Id);
		Id projectId = Id.valueOf(testProject.Id);
		pba__Request__c test = new pba__Request__c();
		test.put('pba__Contact__c', contactId);
		test.put('Project_Look_Up__c', projectId);
		try {
			insert test;
		} catch (DmlException e) {
			System.debug(e.getCause());
			System.debug(e.getMessage());
		}

		System.debug(test.Id);
		Id testId = test.Id;
		test = Database.query('SELECT Id, pba__Contact__r.Email FROM pba__Request__c WHERE id=:testId');

		System.debug(test.pba__Contact__r.Email);
		System.debug(test);
		pba__Request__c loaded = InSiteEnquiryUtils.lookupPropertybaseEnquiryByEmailAddress((String) test.pba__Contact__r.Email);
		System.assertEquals(test.pba__Contact__r.Email, loaded.pba__Contact__r.Email, 'Could not get enquiry by email address');
	}

	@IsTest(SeeAllData=true)
	public static void testById() {
		Contact testContact = new Contact(Salutation='Mr', FirstName='Test', LastName='Person', Email='test.person@email.com', MobilePhone='0400000000', LeadSource='Project Website');
		insert testContact;

		pba__Property__c testProject = new pba__Property__c(RecordTypeId='0122w000001HieuAAC', Name='Test Project');
		insert testProject;

		Id contactId = Id.valueOf(testContact.Id);
		Id projectId = Id.valueOf(testProject.Id);
		pba__Request__c test = new pba__Request__c();
		test.put('pba__Contact__c', contactId);
		test.put('Project_Look_Up__c', projectId);
		insert test;

		pba__Request__c loaded = InSiteEnquiryUtils.lookupPropertybaseEnquiryById(test.Id);
		System.assertEquals(test.Id, loaded.Id, 'Could not get enquiry by email address');
	}
}