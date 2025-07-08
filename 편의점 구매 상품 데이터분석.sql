#1.월별 커피음료 총판매수
select substring(일자,1,7) as month,
		sum(커피음료_페트), sum(커피음료_병), sum(커피음료_중캔), sum(커피음료_소캔)
        from store_order
        group by substring(일자,1,7);

#2. 1번 데이터에서 가장 많이 팔린 음로는 몇 개인지 출력
select substring(일자,1,7) as month,
		greatest(sum(커피음료_페트), sum(커피음료_병), sum(커피음료_중캔), sum(커피음료_소캔)) as greatest
        from store_order
        group by substring(일자,1,7);
        
#3. 1번 데이터에서 커피음료_페트 데이터를 pivot
select '커피음료_페트' as product,
	sum(case when substring(일자,1,7) = '2020-07' then 커피음료_페트 end) as '2020-07',
    sum(case when substring(일자,1,7) = '2020-08' then 커피음료_페트 end) as '2020-08',
    sum(case when substring(일자,1,7) = '2020-09' then 커피음료_페트 end) as '2020-09',
    sum(case when substring(일자,1,7) = '2020-10' then 커피음료_페트 end) as '2020-10'
    from store_order;
    
#4. 월별 탄산수와 생수의 평균 판매수 출력
select substring(일자,1,7) as month,
	floor(avg(탄산수)), floor(avg(생수))
    from store_order
    group by substring(일자,1,7);
    
#5. 월별 비타민워터, 에너지음료, 건강음료 최대 판매수
select substring(일자,1,7) as month,
	max(비타민워터), max(에너지음료),  max(건강음료)
    from store_order
    group by month;
    
    
#1. 가장 비싼 음료 top5
select *from price_info order by price desc limit 5;

#2. 월별 커피음료 매출 구하기
select substring(일자,1,7) as month,
	sum(커피음료_페트) * (select price from price_info where product = '커피음료_페트') as '커피음료_페트',
    sum(커피음료_병) * (select price from price_info where product = '커피음료_병') as '커피음료_병',
    sum(커피음료_중캔) * (select price from price_info where product = '커피음료_중캔') as '커피음료_중캔',
    sum(커피음료_소캔) * (select price from price_info where product = '커피음료_소캔') as '커피음료_소캔'
    from store_order
    group by month;

#3. 10월 3일의 주스 매출 구하기
select 주스_대페트 * (select price from price_info where product = '주스_대페트') as '주스_데페트',
	주스_중페트 * (select price from price_info where product = '주스_중페트') as '주스_중페트',
	주스_캔 * (select price from price_info where product = '주스_캔') as '주스_캔'
    from store_order
    where 일자 = '2020-10-03';

#4. 8월의 이온음료 매출 구하기
select sum(이온음료_대페트) * (select price from price_info where product = '이온음료_대페트') +
	sum(이온음료_중페트) * (select price from price_info where product = '이온음료_중페트') +
    sum(이온음료_캔) * (select price from price_info where product = '이온음료_캔') as total
    from store_order
    where 일자 like '2020-08%';
    
#5. 9월의 차음료 판매수와 매출 구하기
select sum(차음료) as '판매수',
	sum(차음료) * (select price from price_info where product = '차음료') as "매출액"
	from store_order
	where 일자 like '2020-09%';
    

#1. 비가 왔던 날만 출력
select ﻿일시 from weather where 일강수량 > 0;

#2. 최고기온이 30도 이상이었던 날의 아이스음료 판매수 출력
select a.﻿일시, b.아이스음료 , a.최고기온
	from weather a left join store_order b
    on a.﻿일시 = b.일자
	where a.최고기온 >= 30;
    
#3. 최저기온이 20도 미만이었던 날의 건강음료 판매수 출력
select a.﻿일시, b.건강음료 , a.최저기온
	from weather a left join store_order b
    on a.﻿일시 = b.일자
	where a.최저기온 < 20;
    
#4. 비가 왔던 날의 숙취해소음료 판매수 출력
select a.﻿일시, b.숙취해소음료 , a.일강수량
	from weather a left join store_order b
    on a.﻿일시 = b.일자
	where a.일강수량 > 0;

#5. 4번 데이터에 매출 데이터 추가
select a.﻿일시, ifnull(b.숙취해소음료,0) ,
	ifnull(b.숙취해소음료 * (select price from price_info where product = '숙취해소음료'),0) as "매출액",
	a.일강수량
	from weather a left join store_order b
    on a.﻿일시 = b.일자
	where a.일강수량 > 0;