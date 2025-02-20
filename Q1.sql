--Task 1--

-- Q1: The names and the number of messages sent by each user
select 
	u.Name,
	count(m.MessageID) as cnt_messages
from User u
left join Messages m
	on u.UserID = m.UserIDSender
group by 1;

-- Q2: The total number of messages sent stratified by weekday
select 
	extract(dow from DateSent) as dow,
	count(*)
from Messages 
group by 1 ;

-- Q3: The most recent message from each thread that has no response yet
select 
	t.ThreadID,
	m.MessageID,
	m.MessageContent
from Threads t
left join Messages m
	on t.ThreadID = m.ThreadID
qualify row_number() over (partition by t.ThreadID order by m.DateSent desc) = 1;

-- Q4: For the conversation with the most messages: all user data and message
-- contents ordered chronologically so one can follow the whole conversation
with most_message_thread as (
	select 
		t.ThreadID,
		count(m.MessageID) as cnt_messages
	from Threads t
	left join Messages m
		on t.ThreadID = m.ThreadID
	group by 1
	order by 2 desc
	limit 1
)
select 
	m.DateSent,
	m.MessageID,
	m.MessageContent,
	m.UserIDSender,
	us.Name as NameSender,
	m.UserIDRecipient,
	ur.Name as NameRecipient,	
from most_message_thread mmt
left join Messages m
	on mmt.ThreadID = m.ThreadID
left join User us
	on m.UserIDSender = us.UserID
left join User ur
	on m.UserIDRecipient = ur.UserID
order by 1 asc;

