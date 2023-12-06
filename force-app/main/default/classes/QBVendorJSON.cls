public with sharing class QBVendorJSON {
    public String PrintOnCheckName;
    public BillAddr BillAddr;
    public String AcctNum;
    public PrimaryPhone PrimaryPhone;
    public String CompanyName;
    public String FamilyName;
    public WebAddr WebAddr;
    public String SyncToken;
    public Boolean sparse;
    public String DisplayName;
    public Boolean Active;
    public String GivenName;
    public Integer Balance;
    public String domain;
    public String Id;
    public Boolean Vendor1099;
    public MetaData MetaData;
    public PrimaryEmailAddr PrimaryEmailAddr;
	public class WebAddr{
		public String URI;
	}
	public class PrimaryPhone{
		public String FreeFormNumber;
	}
	public class PrimaryEmailAddr{
		public String Address;
	}
	public class MetaData{
		public String CreateTime;
		public String LastUpdatedTime;
	}
	public class BillAddr{
		public String Id;
		public String Lat;
		public String PostalCode;
		public String Long_x;
		public String Line1;
		public String CountrySubDivisionCode;
		public String City;
	}
}