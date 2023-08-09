/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_Soqlable
* Created by Sagar: 04/08/2017
*
* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public virtual interface BT_Soqlable {

    String toSoql();
    
    String toSoql(BT_SoqlOptions options);

}