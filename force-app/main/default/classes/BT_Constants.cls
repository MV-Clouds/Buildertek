/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Util Class: BT_Constants
* Created by Sagar: 06/05/2017
*
* - All constants used in package.

* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */
public with sharing class BT_Constants {
    
    // Tree UI variables
    public static Integer TREE_UI_MAX_NODE = 5000;   
    public static String TREE_UI_MAX_NODE_ID = 'Error_MaxTreeNode';
    public static String TREE_UI_MAX_NODE_CSSCLASS = 'icons/warning.gif';
    public static String TREE_UI_MAX_NODE_ERROR = 'Too many children, displayed first ' + TREE_UI_MAX_NODE;
    
    //NOT SET STRING VALUE either null or ''
    public static String APPURIN_VALUE_NOT_SET = '~Value Not Set~';
    
    // Different types of trees supported
    public static String TREE_TYPE_FILE = 'Files';
    public static String TREE_TYPE_USER = 'Users';
    public static String TREE_TYPE_ACCOUNT = 'Accounts';
    public static String TREE_TYPE_SECTION = 'Section';
    
    // Different types of tree node types. Based on tree node types, children are retrieved and returned.
    public static String TREE_NODE_TYPE_ROOT = 'NodeType_Root';                 // the top most root node that can have static children only as defined in configuration
    public static String TREE_NODE_TYPE_OBJECT = 'NodeType_Object';             // regular object type nodes, node id represent object or special node to retrieve
    public static String TREE_NODE_TYPE_GROUPBY_ROOT = 'NodeType_GroupByRoot';  // group objects by specified field name and return unique field values
    public static String TREE_NODE_TYPE_GROUPBY = 'NodeType_GroupBy';           // find objects where the titleFieldName has value same as the current node
    public static String TREE_NODE_TYPE_QUERY = 'NodeType_Query';               // run query and return specified field values as tree nodes    
    
    // Tree Nodes, special object types for special handling
    public static String TREE_ROOT = 'Root';
    public static String TREE_ROOT_OBJECT = 'RootObject';
    public static String TREE_ROOT_LANDING_PAGE = 'LandingPage';
    public static String TREE_ROOT_LIST_VIEW = 'ListView';
    public static String TREE_ROOT_LIST_VIEW_BY_OBJECT_TYPE = 'ListView_By_OType';
    
    public static String TREE_ROOT_FILES = 'File System';
    
    // Error messages: Define all the error message strings here to help us with easierlocalization later.
    public static String MSG_NO_RECORDS_FOUND = 'No_Records_Found';
    public static String MSG_NO_RECORDS_SELECTED = 'No_Records_Selected';
    
    /**
    Separators to represent (name, value) pairs in string form 
    e.g. Name^Vaue~N2^V2... where ^ is nvSeparator and ~ is pairSeparator
    **/
    public static String SEPARATOR_NAME_VALUE = '#';
    public static String SEPARATOR_NV_PAIR = '~';
    
    // File Access Type
    public static String FILE_ACCESS_PUBLIC_READ_ONLY = 'Public Download Only';
    public static String FILE_ACCESS_PUBLIC_WRITE = 'Public Download & Write';
    public static String FILE_ACCESS_PRIVATE = 'Private';
    
    
    // File Export Type
    public static String FILE_EXPORT_TYPE_EMAIL_ATTACHMENTS = 'Salesforce Email Attachments';
    public static String FILE_EXPORT_TYPE_STANDARD_ATTACHMENTS = 'Salesforce Standard Attachments';
    public static String FILE_EXPORT_TYPE_SALESFORCE_FILES = 'Salesforce Files';
    
    // Metrics type
    public static String METRICS_TYPE_EMAIL_ATTACHMENTS = 'Inbound Email Attachment Container';
    
    // File Upload Status
    public static String FILE_UPLOAD_STATUS_MOVING = 'Moving';
    public static String FILE_UPLOAD_STATUS_COPYING = 'Copying';
    public static String FILE_UPLOAD_STATUS_DELETING = 'Deleting';
    public static String FILE_UPLOAD_STATUS_COMPLETED = 'Completed';
    
    // Application Configurations
    public static String MAX_FILE_SIZE = 'Max File Size';
    public static String AWS_PUBLIC_KEY = 'AWS Public Key';
    public static String AWS_SECRET_KEY = 'AWS Private Key';
    public static String BUCKETS = 'AWS Buckets';
    public static String ENABLE_FILE_DOWNLOAD_HISTORY = 'Enable File Download History';
    public static String FILE_CLEANUP_JOBID = 'Cleanup Job Id';
    public static String FILE_IMPORT_JOBID = 'Import Job Id';
    public static String AMAZON_CANONICAL_USERID = 'AWS Canonical User Id';
    public static String JOB_STATUS_FROM_EMAIL_ADDRESS = 'Job Status From Email Address';
    
    
    // Presigned URL Frequency
    public static String PRESIGNED_URL_FREQUENCY_EVERY_DAY = 'Every Day';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_WEEK = 'Every Week';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_10_DAYS = 'Every 10 Days';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_15_DAYS = 'Every 15 Days';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_MONTH = 'Every Month';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_QUARTER = 'Every Quarter';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_6_MONTHS = 'Every 6 Months';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_YEAR = 'Every Year';
    public static String PRESIGNED_URL_FREQUENCY_EVERY_5_YEARS = 'Every 5 Years';
    
    // Map of days for frequency
    public static Map<String, Integer> FREQUENCY_MAP = 
        new Map<String, Integer>
        {
            PRESIGNED_URL_FREQUENCY_EVERY_DAY           => 1,
            PRESIGNED_URL_FREQUENCY_EVERY_WEEK          => 7,
            PRESIGNED_URL_FREQUENCY_EVERY_10_DAYS       => 10,
            PRESIGNED_URL_FREQUENCY_EVERY_15_DAYS       => 15,
            PRESIGNED_URL_FREQUENCY_EVERY_MONTH         => 30,
            PRESIGNED_URL_FREQUENCY_EVERY_QUARTER       => 90,
            PRESIGNED_URL_FREQUENCY_EVERY_6_MONTHS      => 183,
            PRESIGNED_URL_FREQUENCY_EVERY_YEAR          => 365,
            PRESIGNED_URL_FREQUENCY_EVERY_5_YEARS       => 365*5
        };
        
    // Global File Explorer page configration 
    public static String FILE_EXPLORER_CONFIGURATION = 'File Explorer Page Configuration';
    // Global File Export configration 
    public static String FILE_EXPORT_CONFIGURATION = 'File Export Configuration';
    // Global File Management page Configuration
    public static String FILE_MANAGEMENT_CONFIGURATION = 'File Management Configuration';
    // Global File Upload page configration 
    public static String FILE_UPLOAD_CONFIGURATION = 'File Upload Page Configuration';
    
    public static String RFQ_CONFIGURATION = 'RFQ Configuration';
    
    // Object type constants
    public static String OBJECT_TYPE_ACCOUNT = Account.sObjectType+'';
    public static String OBJECT_TYPE_FILE = File__c.sObjectType+'';
    public static String OBJECT_TYPE_FOLDER = Folder__c.sObjectType+'';
    public static String OBJECT_TYPE_FILE_ACCESS_CONTROL = File_Access_Control__c.sObjectType+'';
    public static String OBJECT_TYPE_PROJECT = Project__c.sObjectType+'';
    
    public static String OBJECT_TYPE_RFQ = RFQ__c.sObjectType+'';
    public static String OBJECT_TYPE_RFQ_ITEM = RFQ_Item__c.sObjectType+'';
    public static String OBJECT_TYPE_PO = Purchase_Order__c.sObjectType+'';
    public static String OBJECT_TYPE_PO_ITEM = Purchase_Order_Item__c.sObjectType+'';
    public static String OBJECT_TYPE_BUDGET = Budget__c.sObjectType+'';
    public static String OBJECT_TYPE_BUDGET_ITEM = Budget_Item__c.sObjectType+'';
    public static String OBJECT_TYPE_CO = Change_Order__c.sObjectType+'';
    public static String OBJECT_TYPE_CO_ITEM = Change_Order_Item__c.sObjectType+'';
    public static String OBJECT_TYPE_RFQ_TO_VENDOR = RFQ_To_Vendor__c.sObjectType+'';
    public static String OBJECT_TYPE_RFQ_TO_VENDOR_ITEM = RFQ_Vendor_Item__c.sObjectType+'';
    public static String OBJECT_TYPE_CONTRACT = Contract__c.sObjectType+'';
    public static String OBJECT_TYPE_CONTRACT_ITEM = Contract_Item__c.sObjectType+'';
    public static String OBJECT_TYPE_QUOTE = Quote__c.sObjectType+'';
    public static String OBJECT_TYPE_QUOTE_ITEM = Quote_Item__c.sObjectType+'';
    public static String OBJECT_TYPE_PROJECT_TASK = Project_Task__c.sObjectType+'';
    public static String OBJECT_TYPE_SCHEDULE = Schedule__c.sObjectType+'';
    public static String OBJECT_TYPE_SECTION = Section__c.sObjectType+'';
    public static String OBJECT_TYPE_QUESTION_GROUP = Question_Group__c.sObjectType+'';
    public static String OBJECT_TYPE_QUESTION = Question__c.sObjectType+'';
    
    public static Map<String, String> OBJECT_NAMESPACE_MAP = 
        new Map<String, String>
        {
             'Account' => OBJECT_TYPE_ACCOUNT,
             'File__c' => OBJECT_TYPE_FILE,
             'Folder__c' => OBJECT_TYPE_FOLDER,
             'File_Access_Control__c' => OBJECT_TYPE_FILE_ACCESS_CONTROL,
             'Quote_Item__c' => OBJECT_TYPE_QUOTE_ITEM,
             'Quote__c' => OBJECT_TYPE_QUOTE,
             'Contract_Item__c' => OBJECT_TYPE_CONTRACT_ITEM,
             'Contract__c' => OBJECT_TYPE_CONTRACT,
             'RFQ_Vendor_Item__c' => OBJECT_TYPE_RFQ_TO_VENDOR_ITEM,
             'RFQ_To_Vendor__c' => OBJECT_TYPE_RFQ_TO_VENDOR,
             'Change_Order_Item__c' => OBJECT_TYPE_CO_ITEM,
             'Change_Order__c' => OBJECT_TYPE_CO,
             'Budget_Item__c' => OBJECT_TYPE_BUDGET_ITEM,
             'Budget__c' => OBJECT_TYPE_BUDGET,
             'Purchase_Order_Item__c' => OBJECT_TYPE_PO_ITEM,
             'RFQ_Item__c' => OBJECT_TYPE_RFQ_ITEM,
             'Project__c' => OBJECT_TYPE_PROJECT,
             'Project_Task__c' => OBJECT_TYPE_PROJECT_Task,
             'RFQ__c' => OBJECT_TYPE_RFQ
        };
    public static Map<String, String> FILE_ICON_MAP = 
        new Map<String, String>
        {
            '.3dm'      => '3dm.png',
            '.3ds'      => '3ds.png',
            '.3gp'      => '3gp.png',
            '.7z'       => '7z.png',
            '.7zip'     => '7zip.png',
            '.aac'      => 'aac.png',
            '.aif'      => 'aif.png',
            '.ai'       => 'ai.png',
            '.apk'      => 'apk.png',
            '.app'      => 'app6.png',
            '.asf'      => 'asf.png',
            '.asp'      => 'asp.png',
            '.aspx'     => 'aspx.png',
            '.asx'      => 'asx.png',
            '.avi'      => 'avi.png',
            '.bak'      => 'bak.png',
            '.bat'      => 'bat.png',
            '.bin'      => 'bin.png',
            '.bmp'      => 'bmp.png',
            '.cab'      => 'cab.png',
            '.cad'      => 'cad.png',
            '.cdr'      => 'cdr.png',
            '.cer'      => 'cer.png',
            '.cfg'      => 'cfg.png',
            '.cfm'      => 'cfm.png',
            '.cgi'      => 'cgi.png',
            '.class'    => 'class.png',
            '.com'      => 'com.png',
            '.cpp'      => 'cpp.png',
            '.crx'      => 'crx.png',
            '.csr'      => 'csr.png',
            '.css'      => 'css.png',
            '.csv'      => 'csv.png',
            '.cue'      => 'cue.png',
            '.cur'      => 'cur.png',
            '.dat'      => 'dat.png',
            '.db'       => 'db.png',
            '.dbf'      => 'dbf.png',
            '.dds'      => 'dds.png',
            '.deb'      => 'deb.png',
            '.dem'      => 'dem.png',
            '.dll'      => 'dll.png',
            '.dmg'      => 'dmg.png',
            '.dmp'      => 'dmp.png',
            '.doc'      => 'doc.png',
            '.docx'     => 'docx.png',
            '.drv'      => 'drv.png',
            '.dtd'      => 'dtd.png',
            '.dwg'      => 'dwg.png',
            '.dxf'      => 'dxf.png',
            '.elf'      => 'elf.png',
            '.eps'      => 'eps.png',
            '.exe'      => 'exe.png',
            '.fla'      => 'fla.png',
            '.flash'    => 'flash.png',
            '.fnt'      => 'fnt.png',
            '.fon'      => 'fon.png',
            '.gbr'      => 'gbr.png',
            '.ged'      => 'ged.png',
            '.gif'      => 'gif.png',
            '.gpx'      => 'gpx.png',
            '.gzip'     => 'gzip.png',
            '.gz'       => 'gz.png',
            '.hqz'      => 'hqz.png',
            '.html'     => 'html.png',
            '.ibooks'   => 'ibooks.png',
            '.icns'     => 'icns.png',
            '.ico'      => 'ico.png',
            '.iff'      => 'iff.png',
            '.indd'     => 'indd.png',
            '.iso'      => 'iso.png',
            '.ipa'      => 'ipa.png',
            '.jar'      => 'jar.png',
            '.jpg'      => 'jpg.png',
            '.js'       => 'js.png',
            '.jsp'      => 'jsp.png',
            '.key'      => 'key.png',
            '.kml'      => 'kml.png',
            '.lnk'      => 'link.png',
            '.log'      => 'log.png',
            '.lua'      => 'lua.png',
            '.m3u'      => 'm3u.png',
            '.m4a'      => 'm4a.png',
            '.max'      => 'max.png',
            '.mdb'      => 'mdb.png',
            '.mdf'      => 'mdf.png',
            '.mid'      => 'mid.png',
            '.mim'      => 'mim.png',
            '.mov'      => 'mov.png',
            '.mp3'      => 'mp3.png',
            '.mp4'      => 'mp4.png',
            '.mpa'      => 'mpa.png',
            '.mpg3'     => 'mpg.png',
            '.msg'      => 'msg.png',
            '.msi'      => 'msi.png',
            '.nes'      => 'nes1.png',
            '.object'   => 'obj.png',
            '.odc'      => 'odc.png',
            '.odf'      => 'odf.png',
            '.odi'      => 'odi.png',
            '.odp'      => 'odp.png',
            '.ods'      => 'ods.png',
            '.odt'      => 'odt.png',
            '.ogg'      => 'ogg.png',
            '.otf'      => 'otf.png',
            '.pages'    => 'pages.png',
            '.pct'      => 'pct.png',
            '.pdb'      => 'pdb.png',
            '.pdf'      => 'pdf.png',
            '.pif'      => 'pif.png',
            '.pkg'      => 'pkg.png',
            '.pl'       => 'pl.png',
            '.png'      => 'png.png',
            '.pps'      => 'pps.png',
            '.ppt'      => 'ppt.png',
            '.pptx'     => 'pptx.png',
            '.psd'      => 'psd.png',
            '.ps'       => 'ps.png',
            '.pub'      => 'pub.png',
            '.python'   => 'py.png',
            '.rar'      => 'rar.png',
            '.ra'       => 'ra.png',
            '.raw'      => 'raw.png',
            '.rm'       => 'rm.png',
            '.rom'      => 'rom.png',
            '.rpm'      => 'rpm.png',
            '.rss'      => 'rss.png',
            '.rtf'      => 'rtf.png',
            '.sav'      => 'sav.png',
            '.sdf'      => 'sdf.png',
            '.sql'      => 'sql.png',
            '.svg'      => 'svg.png',
            '.swf'      => 'swf.png',
            '.sys'      => 'sys.png',
            '.tar'      => 'tar.png',
            '.tex'      => 'tex.png',
            '.tga'      => 'tga.png',
            '.thm'      => 'thm.png',
            '.tiff'     => 'tiff.png',
            '.torrent'  => 'torrent.png',
            '.ttf'      => 'ttf.png',
            '.txt'      => 'text.png',
            '.uue'      => 'uue.png',
            '.vb'       => 'vb.png',
            '.vcd'      => 'vcd.png',
            '.vcf'      => 'vcf.png',
            '.vob'      => 'vob.png',
            '.wav'      => 'wav.png',
            '.wma'      => 'wma.png',
            '.wmv'      => 'wmv.png',
            '.wpd'      => 'wpd.png',
            '.wps'      => 'wps.png',
            '.wsf'      => 'wsf.png',
            '.xlr'      => 'xlr.png',
            '.xls'      => 'xls.png',
            '.xlsx'     => 'xlsx.png',
            '.xml'      => 'xml.png',
            '.yuv'      => 'yuv.png',
            '.zip'      => 'zip.png'
        };    
}