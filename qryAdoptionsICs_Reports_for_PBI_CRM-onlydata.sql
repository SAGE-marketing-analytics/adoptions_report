---- adoptions CRM only data 
-- CRM has older data assigned to generic date in 2017
-- use Term_YY for getting newer / older adoptions 

-- use me!

-- test
-- for 100'000 rows >> .15 sec

use mdw

select distinct top 100000
		 b.last_name as Last_Name,
		 b.first_name as First_Name,
		 b.individual_id,
		 b.email, 
		 b.do_not_email,
		 o.country, 
		 o.state, 
		 o.city,
		 o.RinggoldID,
		 o.mail_organization_name as Organization, 
		 b.department_name AS Department,
		 co.course_category_name AS Course_Category_Name,
		 co.course_name AS Course_Name,
		 co.course_code AS Course_Code,
		 cc.course_discipline_name AS Course_Discipline, 
		 opp.number_of_students AS Enrollment
		 , os.academic_term_year AS Term_Year
		 , bp.ean13_number AS isbn
		 , bk.title_printed as Title
		 , bc.name_printed as Primary_Author_Name
		 , bk.marketing_manager
		 , opp.opportunity_created_date AS Opportunity_Date
		 , case ISNULL((prdSpec.adopted_flag),'') when 'Y' then 'Adopted' 
			else 'Inspection' end as Adoption_Status
		 , adoption_level

from f_opportunity opp
    join f_opportunity_product c        on opp.mdw_opportunity_key = c.mdw_opportunity_key
    join d_opportunity_product_specification prdSpec
										on c.mdw_opportunity_product_specification_key = prdSpec.mdw_opportunity_product_specification_key
    join d_opportunity_specification os on opp.mdw_opportunity_specification_key = os.mdw_opportunity_specification_key

    join book_product bp				on bp.book_product_id = c.book_product_id
    join book bk						on bp.book_id = bk.book_id
    join a2r.d_product ar				on CONVERT(nvarchar(20), ar.isbn13,0) = bp.ean13_number
	left join book_contributor bc		on bc.book_id = bk.book_id
													and (bc.authored_yn = 1 and bc.sequence = 1) 

    left join d_course co				on opp.mdw_course_key=co.mdw_course_key
    left join course_category cc		on co.course_code=cc.course_code

    join individual b				    on opp.individual_id = b.individual_id and b.email is  not null
    join organization o				    on o.organization_id = b.organization_id and o.RinggoldID is not null

where 
	b.do_not_email like 'N%'