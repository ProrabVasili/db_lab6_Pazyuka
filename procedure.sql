-- Процедура видаляє певний тип кухні із ресторану певного міста

DROP PROCEDURE IF EXISTS del_rest_cuisine(rest_name VARCHAR(30), 
										  city_name VARCHAR(30),
										  cuisine_name VARCHAR(30)); 
CREATE OR REPLACE PROCEDURE del_rest_cuisine(rest_name VARCHAR(30), 
											city_name VARCHAR(30),
											cuisine_name VARCHAR(30))  
LANGUAGE plpgsql
AS $$
DECLARE rest_id restaurant.restaurant_id%TYPE;
DECLARE cit_id location.city_id%TYPE;
DECLARE cuis_id cuisine.cuisine_id%TYPE;
BEGIN
	SELECT city_id INTO cit_id
	FROM location
	WHERE city = city_name;
	
	IF cit_id IS NULL THEN
		RAISE INFO '"%" could not be found in list of cities', city_name;
	ELSE
		SELECT restaurant_id, city_id INTO rest_id, cit_id
		FROM restaurant
		WHERE restaurant_name = rest_name 
		AND  city_id = cit_id;
		
		SELECT cuisine_id INTO cuis_id
		FROM cuisine
		WHERE type_cuisine = cuisine_name;

	   	IF rest_id IS NULL THEN
			RAISE INFO '"% could not be found in list of restaurants in this city', rest_name;
		ELSIF cuis_id IS NULL THEN
			RAISE INFO '"%" could not be found in list of cuisines', cuisine_name;
		ELSE
			DELETE FROM restaurant_cuisine
			WHERE restaurant_id = rest_id AND cuisine_id = cuis_id;

			RAISE INFO 'Successfully!';
		END IF;
	END IF;
END;
$$;


