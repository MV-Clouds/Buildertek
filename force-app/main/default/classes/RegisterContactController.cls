public with sharing class RegisterContactController {

    public String FirstName { get; set; }
    public String LastName { get; set; }
    public String Email { get; set; }
    public String MobilePhone { get; set; }
    public String CompanyName { get; set; }
    
    public String successMessage { get; set; }
    public String errorMessage { get; set; }
    public Boolean showSuccess { get { return successMessage != null && successMessage != ''; } set; }
    public Boolean showError { get { return errorMessage != null && errorMessage != ''; } set; }
    
    public List<Contact> contacts { get; set; }
    public List<Account> companies { get; set; }
    
    public String selectedCompany { get; set; }
    public String selectedContact { get; set; }
    
    public pba__Listing__c listing { get; set; }
    
    public RegisterContactController(ApexPages.StandardController controller) {
        listing = (pba__Listing__c)controller.getRecord();
        System.debug('Created Register Contact Page for listing: ' + listing.Id);
    }
    
    public String sql {
        get {
            string sql = 'SELECT id, Name, FirstName, LastName, Email, MobilePhone FROM Contact WHERE isdeleted = false';
            if (FirstName != '' && FirstName != null)
                sql += ' AND FirstName LIKE \'%' + FirstName + '%\'';
            if (LastName != '' && LastName != null)
                sql += ' AND LastName LIKE \'%' + LastName + '%\'';
            if (Email != '' && Email != null)
                sql += ' AND Email LIKE \'' + Email + '%\'';
            if (MobilePhone != '' && MobilePhone != null)
                sql += ' AND MobilePhone LIKE \'' + MobilePhone + '%\'';
            return sql + ' ORDER BY Name LIMIT 10';
        }
    }
    
    public PageReference companySearch() {
        String companySearch = '%' + companyName + '%';
        System.debug('Searching companies for: ' + companySearch);
        companies = [SELECT id, Name FROM Account WHERE pba__SystemIsIndividual__c = false AND name LIKE :companySearch LIMIT 4];
        System.debug('Found companies: ' + companies);
        return null;
    }
    
    public PageReference search() {
        try {
            if (FirstName == '' && LastName == '' && Email == '' && MobilePhone == '')
                contacts = new List<Contact>();
            else
                contacts = Database.query(sql);
        } catch (Exception e) {
            System.debug('Error: Line ' + e.getLineNumber());
            System.debug('Error: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Error: ' + e.getMessage()));
        }
        System.debug('Query: "' + sql + '"');
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Debug: ' + sql));
        return null;
    }
    
    public PageReference save() {
        errorMessage = '';
        successMessage = '';
        
        System.debug('CompanyName: ' + companyName);
        System.debug('selectedCompany: ' + selectedCompany);
        
        if (LastName == '' || LastName == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot create contact as lastname cannot be empty'));
            errorMessage = 'Error: Contact must have a last name';
            System.debug(errorMessage);
            return null;
        }
        
        String leadSourceSetting = pba.Settings.getSettingValue('register_contact_leadsource');
        
        Contact contact = new Contact();
        contact.FirstName = FirstName;
        contact.LastName = LastName;
        contact.Email = Email;
        contact.MobilePhone = MobilePhone;
        contact.Leadsource = String.isBlank(leadSourceSetting)? 'Inspection' : leadSourceSetting;
        
        if (CompanyName != '' && CompanyName != null) {
            if (selectedCompany == 'individual' || selectedCompany == '') { 
                contact.pba__SystemIsIndividual__c = true;
                contact.pba__CompanyName__c = CompanyName;
            } else if (selectedCompany == 'new') {
                Account a = new Account();
                a.Name = CompanyName;
                a.pba__SystemIsIndividual__c = false;
                insert a;
                
                contact.AccountId = a.Id;
            } else {
                contact.pba__CompanyName__c = CompanyName;
                contact.AccountId = selectedCompany;
            }
        }
        
        try {
            insert contact;
        } catch (System.DmlException e) {
            errorMessage = 'Error: ' + e.getDmlMessage(0);
            System.debug(errorMessage);
            return null;
        }
        
        successMessage = 'Your new contact <a href="/' + contact.id + '">' + contact.FirstName + ' ' + contact.LastName + '</a> was successfully created.';
        System.debug(successMessage);
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Contact created: ' + contact.id));
        System.debug('Contact created: ' + contact.id);
        
        if (listing.Id != null) {
            selectedContact = contact.Id;
            linkTheContact();
        }
        
        FirstName = '';
        LastName = '';
        Email = '';
        MobilePhone = '';
        CompanyName = '';
        
        search();
               
        return null;
    }
    
    private void linkTheContact() {
        // create request
        pba__Request__c request = new pba__Request__c();
        request.pba__Contact__c = selectedContact;
        request.Enquiry_Source__c = 'Inspection';
        insert request;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Created request: ' + request.Id));
        System.debug('Created request: ' + request.Id);
        
        // create favorite
        pba__Favorite__c favorite = new pba__Favorite__c();
        favorite.pba__Contact__c = selectedContact;
        favorite.pba__Request__c = request.Id;
        favorite.pba__Listing__c = listing.Id;
        insert favorite;
        
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Create favorite: ' + favorite.Id));
        System.debug('Create favorite: ' + favorite.Id);
    }
    
    public PageReference linkContact() {
        System.debug('Linking contact: "' + selectedContact + '"');
        successMessage = '';
        errorMessage = '';
        try {
            linkTheContact();
        } catch (Exception e) {
            errorMessage = e.getMessage();
            return null;
        }
        
        successMessage = 'Contact linked successfully';
        System.debug(successMessage);
        System.debug('show: ' + showSuccess);
        
        return null;
    }
}