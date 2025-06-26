use masterclass;
#전국 휴게소 각종 데이터 join
#1. 고속도로 휴게소의 규모와 주차장 현황을 함께 출력(휴게소명, 시설구분, 합계, 대대형, 수형, 장애인)
select * from rest_area_score;
select * from rest_area_parking;

select a.휴게소명, a.시설구분, b.합계, b.대형, b.소형, b.장애인
from rest_area_score a left outer join rest_area_parking b
on a.휴게소명 = b.휴게소명
union
select b.휴게소명, a.시설구분, b.합계, b.대형, b.소형, b.장애인
from rest_area_score a right outer join rest_area_parking b
on a.휴게소명 = b.휴게소명;


#2. 고속도로 휴게소의 규모와 현황을 함께 출력(휴게소명, 시설구분, 남자_변기수, 여자_변기수)
select * from rest_area_toilet;
select * from rest_area_score;

select a.휴게소명, a.시설구분, b.남자_변기수, b.여자_변기수
from rest_area_score a left outer join rest_area_toilet b
on a.휴게소명 = b.시설명
union
select b.시설명, a.시설구분, b.남자_변기수, b.여자_변기수
from rest_area_score a right outer join rest_area_toilet b
on a.휴게소명 = b.시설명;


#3. 고속도로 휴게소의 규모, 주차장, 화장실 현황을 함께 출력(휴세고명, 시설구분, 합계, 남자_변기수, 여자_변기수)
select a.휴게소명, a.시설구분, b.합계, c.남자_변기수, c.여자_변기수
from rest_area_score a, rest_area_parking b, rest_area_toilet c
where a.휴게소명 = b.휴게소명 and b.휴게소명 = c.시설명;


#4. 고속도로 휴게소 규모별로 주차장수 합계의 평균, 최소값, 최댓값 출력
select a.휴게소명, a.시설구분, avg(b.합계) over (partition by a.시설구분) as avg_parking,
min(b.합계) over (partition by a.시설구분) as min_parking,
max(b.합계) over (partition by a.시설구분) as max_parking
from rest_area_score a inner join rest_area_parking b
on a.휴게소명 = b.휴게소명;


#5. 고속도로 휴게소 만족도별로 대형 주차장수가 가장 많은 휴게소만 출력
select t.휴게소명, t.평가등급, t.대형 
from(
select a.휴게소명, a.평가등급, b.대형,
rank() over(partition by a.평가등급 order by b.대형 desc) as rnk
from rest_area_score a, rest_area_parking b
where a.휴게소명 = b.휴게소명
) t
where rnk = 1;

#전국 휴게소 화장실 실태 조사
#1.노선별 남자 변기수, 여자 변기수 최대값 출력
select * from rest_area_toilet;
select ﻿노선, max(남자_변기수), min(여자_변기수)
from rest_area_toilet
group by ﻿노선;


#2. 휴게소 중 total 변기수가 가장 많은 휴게소가 어디인지 출력
select 시설명, 남자_변기수 + 여자_변기수 as total from rest_area_toilet
order by total desc limit 1;


#3. 노설별로 남자_변기수, 여자_변기수의 평균값 출력
select ﻿노선, round(avg(남자_변기수)), round(avg(여자_변기수)) from rest_area_toilet
group by ﻿노선;


#4. 노선별로 total 변기수가 가장 많은 곳만 출력
select ﻿노선, 남자_변기수 + 여자_변기수 as total,
rank() over(partition by ﻿노선 order by 남자_변기수+여자_변기수 desc) as rnk
from rest_area_toilet;

select t.﻿노선, t.total from(
select ﻿노선, 남자_변기수 + 여자_변기수 as total,
	rank() over(partition by ﻿노선 order by 남자_변기수+여자_변기수 desc) as rnk
	from rest_area_toilet
) t where t.rnk = 1;


#5. 노선별로 남자 변기수가 더 많은 곳, 여자 변기수가 더 많은 곳, 남녀 변기수가 동일한 곳의 count를 각각 구하여 출력
select ﻿노선,
	count(case when 남자_변기수 > 여자_변기수 then 1 end) as male,
    count(case when 남자_변기수 < 여자_변기수 then 1 end) as female,
    count(case when 남자_변기수 = 여자_변기수 then 1 end) as equal,
    count(*) as total
from rest_area_toilet group by ﻿노선;

#만족도가 높은 휴게소의 편의시설 현황
#1. 평가등급이 최우수인 휴게소의 장애인 주차장수 출력(휴세고명, 시설구분, 장애인 주차장수 내림차순으로 출력)
select a.휴게소명, a.시설구분, b.장애인 
from (
	select 휴게소명, 시설구분 from rest_area_score where ﻿평가등급 = '최우수'
    ) a left outer join rest_area_parking b
    on a.휴게소명 = b.휴게소명
    order by b.장애인 desc;

#2. 평가등급이 우수인 휴게소의 장애인 주차장수 비율 출력(휴게소명, 시설구분, 장애인 주차장수 비율 내림차순으로 출력)
select s.휴게소명, s.시설구분, round(p.장애인/p.합계* 100,2) as ratio
from (
	select 휴게소명, 시설구분
    from rest_area_score
    where ﻿평가등급 = '우수'
    ) s left outer join rest_area_parking p
on s.휴게소명 = p.휴게소명
order by p.장애인/p.합계 * 100 desc;

#3. 휴게소의 시설구분별 주차장수 합계의 평균 출력
select a.시설구분, round(avg(b.합계))
from rest_area_score a, rest_area_parking b
where a.휴게소명 = b.휴게소명
group by a.시설구분;

#4. 노선별로 대형차를 가장 많이 주차할 수 있는 휴게소 top3
select t.﻿노선, t.대형, t.휴게소명 from(
	select a.﻿노선, b.대형, b.휴게소명,
		rank() over(partition by a.﻿노선 order by b.대형 desc) as rnk
	from rest_area_toilet a, rest_area_parking b
    where a.시설명 = b.휴게소명
) t
where t.rnk < 4;

#5. 본부별로 소형차를 가장 많이 주차할 수 있는 휴게소 top3
select t.﻿본부, t.휴게소명, t.소형 from(
	select ﻿본부, 휴게소명, 소형, rank() over(partition by ﻿본부 order by 소형 desc) as rnk
	from rest_area_parking
) t 
where t.rnk < 4;


#반려동물을 데리고 와이파이 빵빵한 휴게소에 가보자!
select *from rest_area_animal;
select * from rest_area_wifi;
#1. 반려동물 놀이터가 있는 휴게소 중 wifi 사용이 가능한 곳 출력
select * from rest_area_wifi a left outer join rest_area_animal b
on a.휴게소명 = b.﻿휴게소명 where a.가능여부 = 'O';

#2. 반려동물 놀이터가 있는 호게소 중 운영시간이 24시간인 곳이 몇 군대인지 출력
select count(*) from rest_area_animal where 운영시간 = '24시간';

#3. 본부별로 wifi 사용이 가능한 휴게소가 몇 군데인지 출력
select ﻿본부, count(*) from rest_area_wifi
where 가능여부 = 'O'
group by ﻿본부;

#4. 3번 데이터를 휴게소가 많은 순서대로 정렬하여 출력
select ﻿본부, count(*) from rest_area_wifi
where 가능여부 = 'O'
group by ﻿본부 order by count(*) desc;

#5. 4번 데이터에서 휴게소 수가 25보다 많은 곳만 출력
select ﻿본부, count(*) from rest_area_wifi
where 가능여부 = 'O'
group by ﻿본부 
having count(*) > 25
order by count(*) desc;

