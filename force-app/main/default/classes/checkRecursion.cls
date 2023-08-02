public Class checkRecursion{
    private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
      public Static void setAlredyRun(){
        run=true;
    }
}