public without sharing class QBVendorResponseJSON {
    public Vendor Vendor;
		// public String time;
	public class WebAddr{
		public String URI;
	}
	public class Vendor{
		public String FamilyName;
		public String PrintOnCheckName;
		public String SyncToken;
		public String AcctNum;
		public String CompanyName;
		public PrimaryPhone PrimaryPhone;
		public WebAddr WebAddr;
		public BillAddr BillAddr;
		public Boolean sparse;
		public String DisplayName;
		public Boolean Active;
		public String GivenName;
		public Double Balance;
		public String domain;
		public String Id;
		public Boolean Vendor1099;
		public MetaData MetaData;
		public PrimaryEmailAddr PrimaryEmailAddr;
	}
	public class PrimaryPhone{
		public String FreeFormNumber;
	}
	public class PrimaryEmailAddr{
		public String Address;
	}
	public class MetaData{
		public String LastUpdatedTime;
		public String CreateTime;
	}
	public class BillAddr{
		public String CountrySubDivisionCode;
		public String Lat;
		public String PostalCode;
		// public String Long;
		public String Line1;
		public String Id;
		public String City;
	}

	public QueryResponse QueryResponse;
	public class QueryResponse{
		public Integer startPosition;
		public Integer maxResults;
		public list<Vendor> Vendor;
		public Integer totalCount;
	}

    public static QBVendorResponseJSON parse(String json) {
		return (QBVendorResponseJSON) System.JSON.deserialize(json, QBVendorResponseJSON.class);
	}
}