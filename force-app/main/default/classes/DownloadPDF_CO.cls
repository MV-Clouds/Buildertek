public class DownloadPDF_CO {
public string output{get;set;}
    public string Headermargin{get;set;}
    public string Footermargin{get;set;}
    public string HeaderFirstmargin{get;set;}
    public string FooterFirstmargin{get;set;}   
    public string height{get;set;}
    public string heightsecond{get;set;}  
    public String getPrintView(){
        return
            '<!--[if gte mso 9]>' +
            '<xml>' +
            '<w:WordDocument>' +
            '<w:View>Print</w:View>' +
            '<w:Zoom>100</w:Zoom>' +
            '<w:DoNotOptimizeForBrowser/>' +
            '</w:WordDocument>' +
            '</xml>' +
            '<![endif]>';
    }
     public DownloadPDF_CO(){          
        Headermargin = '0.1in';
        Footermargin = '0.1in';
        FooterFirstmargin = '0.01in';
        HeaderFirstmargin = '0.01in';
        
        System.debug((ApexPages.currentPage().getParameters().get('DocTemplateId')));
        Id DocTemplateId = id.valueof(ApexPages.currentPage().getParameters().get('DocTemplateId')); 
        
        string TemplateID = '';
       
        if(DocTemplateId!=null){ // selected Available Template Id
            TemplateID = DocTemplateId;
        }
         
     }
         
          public PageReference methodone(){
        System.debug('Test');
        string QuoteIds = ApexPages.currentPage().getParameters().get('id');
        System.debug('QuoteIds=='+QuoteIds);
        list<string> QuotelistIds = (list<string>)JSON.deserialize(QuoteIds, list<string>.class);
        string DocTemplateIds = id.valueof(ApexPages.currentPage().getParameters().get('DocTemplateId'));        
        output='';
        integer i = 1;
        for(String str:QuotelistIds){
            System.debug('RecordId : '+str+'  Templateid : '+DocTemplateIds);
            PageReference ref = new PageReference('/apex/buildertek__BT_GenerateCOpdf?recordId='+str+'&templateId='+DocTemplateIds);
            if(i < QuotelistIds.size()){
                if(!test.isRunningTest()){
                    output += string.valueof( ref.getcontent().tostring().trim() + '')+'<p style="page-break-after: always;"/>';
                }
            }
            else{
                if(!test.isRunningTest()){
                    output += string.valueof( ref.getcontent().tostring().trim() + '');
                }
            }
            i = i+1;
        }
        output  = output.unescapeHtml4(); 
        output = output.replace('<div style="font-size: 0px;">"</div>','');
        output = output.replace('<div class="content">null','<div class="content">');
        return null; 
    }  
}