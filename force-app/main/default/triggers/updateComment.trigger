trigger updateComment on CaseComment (after insert, after update) 
{
Integer count = 0;
 if(checkRecursive.runOnce())
    {
Map<Id,CaseComment> cMap = new Map<Id,CaseComment>();
string body;
for (CaseComment t: Trigger.new){
 cMap.put(t.ParentId,t);
body = t.CommentBody;
}
 
 
Set<Id> idSet = cMap.keySet();
List<Case> allCases = [select Id,ParentId,recordTypeid from Case where Id in :idSet];
List<CaseComment> childCom = new List<CaseComment>();

{
for(integer i=0;i<allCases.size();i++){
System.debug('@@ '+allCases[i].ParentId);
if(allCases[i].ParentId!=null)
{
  CaseComment newCom = new CaseComment();
 newCom.CommentBody = body;
 newCom.IsPublished = TRUE;
 newCom.ParentId = allCases[i].parentId;
 childCom.add(newcom);
}
}
if(!childCom.isEmpty()){
try{
insert childCom;}
catch(exception ex) {    trigger.New[0].adderror('There are some fields missing on parent case');
    
    }

}
}
}
}