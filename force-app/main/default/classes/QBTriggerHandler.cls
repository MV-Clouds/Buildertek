public class QBTriggerHandler {
    public static void createAcc(List<Account> Acc){
        Account Ac = Acc[0];
        QBMap.mapAccountData(Ac, 1);
    }

    public static void updateAcc(List<Account> Acc){
        Account Ac = Acc[0];
        QBMap.mapAccountData(Ac, 2);
    }
    
    public static void deleteAcc(List<Account> Acc){
        Account Ac = Acc[0];
        QBMap.mapAccountData(Ac, 3);
    }

}