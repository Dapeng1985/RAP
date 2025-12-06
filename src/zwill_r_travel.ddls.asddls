@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity zwill_r_travel
  as select from zwill_travel
{
  key agency_id   as AgencyId,
  key travel_id   as TravelId,
      description as Description,
      customer_id as CustomerId,
      begin_date  as BeginDate,
      end_date    as EndDate,
      status      as Status,
      @Semantics.systemDateTime.lastChangedAt: true
      changed_at  as ChangedAt,
      @Semantics.user.lastChangedBy: true
      changed_by  as ChangedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at as CreatedAt,
      @Semantics.user.createdBy: true
      created_by as CreatedBy
      
}
