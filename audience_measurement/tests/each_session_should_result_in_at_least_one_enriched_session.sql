with 
failed_joins AS (
    select *
    from {{ ref('session') }} s
            left join {{ ref('enriched_session') }} es
                    on s.channel = es.common_channel
                        and s.users = es.users
                        and es.beginning >= s.beginning and es.finish <= s.finish
    where es.users is NULL),
    
number_of_failed_joins AS
    (SELECT COUNT(*) as fails from failed_joins)

SELECT * FROM number_of_failed_joins WHERE fails > 100