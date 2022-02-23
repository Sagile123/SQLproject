--------חלק א------
---	Q2	----
select d.PlayerID,d.[Date ],d.TimeOnApp,d.Games,ISNULL( pt.revenu,0) as revenu,ISNULL( tt.totaltransaction,0) as totaltransaction
into DailyDataNew
from DailyData d left join (select t.PlayerID,t.[Date ],SUM(PriceValue) as revenu 
							from Transactions T, Prices P
							where t.PriceID=p.PriceID 
						    group by t.PlayerID  ,t.[Date ]  ) pt
on d.PlayerID= pt.PlayerID and d.[Date ]=pt.[Date ] left join (select t.PlayerID , COUNT(t.PlayerID) as totaltransaction
																from Transactions t
																group by t.PlayerID) tt
on tt.PlayerID=d.PlayerID

--------Q3-----


select p.PlayerID,p.Platform,p.LoginType,p.Country,p.LifeTimeRevenue,p.InstallDate,dnd.MinOrderDate,dnd.MaxOrderDate,dnt.Trevenu+p.LifeTimeRevenue as LTRevenueNew , case when p.LifeTimeRevenue>0 or dnt.Trevenu>0 then 'yes' else 'no' end as 	IsSpenderNew  ,case when DATEDIFF(YEAR,p.installdate,GETDATE())<=1 then '1 year' 
																																																												when DATEDIFF(YEAR,p.installdate,GETDATE()) > = 2 and DATEDIFF(YEAR,p.installdate,GETDATE())<= 3 then '2-3 years' 
																																																											    when DATEDIFF(YEAR,p.installdate,GETDATE()) > 3 then '3 years+' end as Seniority 
into PlayersNew 
from Players p left join (select dn.PlayerID,SUM(dn.revenu) as Trevenu
							 from DailyDataNew dn
							 group by dn.PlayerID) dnt on dnt.PlayerID=p.PlayerID 
left join (	select dn.PlayerID,MIN(dn.[Date ]) as MinOrderDate,MAX(dn.[Date ])as MaxOrderDate
from DailyDataNew dn
where dn.revenu> 0
group by dn.PlayerID) dnd on dnd.PlayerID=p.PlayerID

	

------Q4-----
select dn.PlayerID,dn.[Date ],dn.TimeOnApp,dn.Games,dn.revenu,dn.totaltransaction,pn.Platform,pn.LoginType,pn.Country,pn.InstallDate,pn.MinOrderDate,pn.MaxOrderDate,pn.LTRevenueNew,pn.IsSpenderNew,pn.Seniority,case when dn.[Date ]=pn.MinOrderDate  and pn.LifeTimeRevenue=0  then '1' else '0' end as FTD  
into DailyDataAll 
from DailyDataNew dn ,PlayersNew pn
where dn.PlayerID=pn.PlayerID
order by FTD

---------חלק ב-----

------Q5-----
select dda.[Date ], dda.Platform,dda.Country,dda.LoginType,dda.Seniority,COUNT(dda.PlayerID) as SumDailyCustomers,SUM(case when dda.revenu=1 then 1 else 0 end) as PCustomers, sum(case when dda.FTD =1 then 1 else 0 end) FTD, sum(dda.revenu) as revenu,SUM(totaltransaction) as TotalTransaction,sum(dda.TimeOnApp) as TimeOnApp, COUNT(dda.Games) as Games
from DailyDataAll dda
group by dda.[Date ], dda.Platform,dda.Country,dda.LoginType,dda.Seniority
order by 1,2,3,4,5

-----חלק ג-------

----Q8-----
select DDA.*,case when DDA.PlayerID=tg.PlayerID then 'test' else 'control' end as  TestGroup
into ABTest 
from DailyDataAll DDA left join TestGroup TG
on dda.PlayerID=Tg.PlayerID


select *
from ABTest