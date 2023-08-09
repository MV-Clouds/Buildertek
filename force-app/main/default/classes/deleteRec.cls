public class deleteRec {
    public static void deleterec(){
        buildertek__Change_Order__c[] d=[select id,name from buildertek__Change_Order__c where Name='Oct 11'];
        delete d;
        System.debug('success');
    }
}