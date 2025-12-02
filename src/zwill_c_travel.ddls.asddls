@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View:Travel Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true   //允许对该View进行Metadata扩展

@Search.searchable: true
define root view entity zwill_c_travel
  provider contract transactional_query
  as projection on zwill_r_travel
{
      @Search.defaultSearchElement: true
  key AgencyId,
  key TravelId,
      Description,
      @Search.defaultSearchElement: true
      CustomerId,
      BeginDate,
      EndDate,
      Status,
      ChangedAt,
      ChangedBy
}
