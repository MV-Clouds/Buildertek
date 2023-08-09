public with sharing class BTCloneProject {

    @AuraEnabled
    public static buildertek__Project__c getProjects(String projectId) {
        buildertek__Project__c project = [SELECT Id, Name, buildertek__County__c, buildertek__County_Text__c from buildertek__Project__c where Id = :projectId];
        return project;
    }

    public BTCloneProject() {

    }
}