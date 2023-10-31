public class QBTriggerHandler {
    public static void createAcc(List<Account> Acc){
        Account Ac = Acc[0];
        QBMap.mapAccountData(Ac);
    }

    public static void updateAcc(List<Account> Acc){
        Account Ac = Acc[0];
        QBMap.mapAccountData2(Ac);
    }
    
    public static void deleteAcc(List<Account> Acc){
        Account Ac = Acc[0];
        QBMap.mapAccountData3(Ac);
    }

}