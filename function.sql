-- Сортований рейтинг ресторанів у певному місті за певним типом кухні

DROP FUNCTION IF EXISTS rating_rest_by_cuisine(city_name VARCHAR(30),
										        cuisine_name VARCHAR(30));
												
CREATE OR REPLACE FUNCTION rating_rest_by_cuisine(city_name VARCHAR(30),
											 cuisine_name VARCHAR(30))  
RETURNS TABLE (rest_name VARCHAR(30), rating_score FLOAT)
LANGUAGE plpgsql
AS $$
DECLARE cit_id location.city_id%TYPE;
DECLARE cuis_id cuisine.cuisine_id%TYPE;
BEGIN
	SELECT city_id INTO cit_id
	FROM location
	WHERE city = city_name;
	
	SELECT cuisine_id INTO cuis_id
	FROM cuisine
	WHERE type_cuisine = cuisine_name;
	
	IF cit_id IS NULL THEN
		RAISE INFO '"%" could not be found in list of cities', city_name;
	ELSIF cuis_id IS NULL THEN
		RAISE INFO '"%" could not be found in list of cuisines', cuisine_name;
	ELSE
		RAISE INFO 'Successfully!';
	END IF;
	
    RETURN QUERY
         SELECT restaurant_name::VARCHAR(30), rating::FLOAT
         FROM restaurant
		 JOIN restaurant_cuisine USING(restaurant_id)
         WHERE city_id = cit_id AND cuisine_id = cuis_id
		 ORDER BY rating DESC;
END;
$$