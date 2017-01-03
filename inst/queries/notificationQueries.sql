with clickDateids as(
/* Get the user and clicked date ids for each notification */

select nef.notification_id as notification_id
	, nef.notification_delivery_channel_id as delivery_channel_id
	, nef.user_id as user_id
	, nef.date_id as sent_date_id
	, ncf.date_id as clicked_date_id
	, nuf.date_id as unsubscribe_date_id
	, nmf.date_id as manage_settings_date_id
from notification_event_facts nef
left join notification_click_thru_facts ncf
on ncf.notification_id=nef.notification_id
left join notification_unsubscribe_click_facts nuf
on nuf.notification_id=nef.notification_id
left join notification_manage_settings_facts nmf
on nmf.notification_id=nef.notification_id
order by ncf.date_id, nef.date_id, nuf.date_id
), clickDates as(
/* Convert date ids to dates */

select clickDateids.notification_id as notification_id
	, clickDateids.user_id as user_id
	, clickDateids.delivery_channel_id as delivery_channel_id
	, ddnef.calendar_week_start_date as sent_week_start_date
	, ddncf.calendar_week_start_date as clicked_week_start_date
	, ddnuf.calendar_week_start_date as unsubscribe_week_start_date
	, ddnmf.calendar_week_start_date as manage_settings_week_start_date
from clickDateids
left join date_dim ddnef
on ddnef.id=clickDateids.sent_date_id
left join date_dim ddncf
on ddncf.id=clickDateids.clicked_date_id
left join date_dim ddnuf
on ddnuf.id=clickDateids.unsubscribe_date_id
left join date_dim ddnmf
on ddnmf.id=clickDateids.manage_settings_date_id
), email_only_notifications as(

select distinct id
from notification_delivery_channel_dimensions
where delivery_channel='email'
), clickDates_email_only as(
/* Throw out push notifications */

select *
from clickDates c
inner join email_only_notifications eon
on c.delivery_channel_id=eon.id
), clicked01 as(
/* Flag each notification as clicked or unclicked */

select 
	clickDates_email_only.notification_id
	, clickDates_email_only.user_id
	, clickDates_email_only.sent_week_start_date
	, case
       		when clickDates_email_only.clicked_week_start_date is null
		then 0
		else 1
	end as was_clicked	
	, case
       		when clickDates_email_only.clicked_week_start_date
			=clickDates_email_only.sent_week_start_date
		then 1
		else 0
	end as was_clicked_same_week	
	, case
       		when clickDates_email_only.unsubscribe_week_start_date is null
		then 0
		else 1
	end as was_unsubscribed	
	, case
       		when clickDates_email_only.unsubscribe_week_start_date
			=clickDates_email_only.sent_week_start_date
		then 1
		else 0
	end as was_unsubscribed_same_week	
	, case
       		when clickDates_email_only.manage_settings_week_start_date is null
		then 0
		else 1
	end as was_managed	
	, case
       		when clickDates_email_only.manage_settings_week_start_date
			=clickDates_email_only.sent_week_start_date
		then 1
		else 0
	end as was_managed_same_week	
from clickDates_email_only
), notification_types as(
select id as notification_id
	, event_type
from notification_dimensions
), clicked01_with_aggregators as(
select *
from clicked01
left join notification_types
on notification_types.notification_id=clicked01.notification_id
), aggregate as(
/* Aggregate */

select sent_week_start_date
	, event_type
	, count(*) as notification_count
	, sum(was_clicked) as click_count
	, sum(was_clicked_same_week) as click_count_same_week
	, sum(was_unsubscribed) as unsubscribe_count
	, sum(was_unsubscribed_same_week) as unsubscribe_count_same_week
	, sum(was_managed) as manage_count
	, sum(was_managed_same_week) as manage_count_same_week
from clicked01_with_aggregators
group by sent_week_start_date
	, event_type
order by sent_week_start_date
	, event_type
)
/* Return actual results */
select *
from aggregate
;
