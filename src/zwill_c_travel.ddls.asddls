@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View:Travel Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true   //允许对该View进行Metadata扩展

@Search.searchable: true
define root view entity zwill_c_travel
  provider contract transactional_query
  as projection on zwill_r_travel
{
  key uuid,
      @Search.defaultSearchElement: true
      AgencyId,
      TravelId,
      Description,
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity:{ name: '/DMO/I_Customer_StdVH', element: 'CustomerID' },
                                           additionalBinding: [{ localElement: 'Description', element:'FirstName', usage: #RESULT }],
                                           qualifier:  '1', label: 'VHelp1' },
                                         { entity: { name: '/DMO/I_Customer', element: 'CustomerID' },
                                           additionalBinding: [{ localElement: 'Description', element: 'FirstName', usage: #RESULT }],
                                           qualifier: '2', label: 'VHelp2' }
                                        ]
      CustomerId,
      BeginDate,
      EndDate,
      Status,
      ChangedAt,
      ChangedBy,
      LocChangedAt
}
