/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_SoqlNestableCondition
* Created by Sagar: 04/08/2017
*
* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public interface BT_SoqlNestableCondition extends BT_SoqlCondition{
    BT_SoqlNestableCondition add(BT_SoqlCondition c);
}