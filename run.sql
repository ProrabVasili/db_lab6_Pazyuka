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

-- SELECT *
-- FROM rating_rest_by_cuisine('Mumbai', 'Bakery');

-- SELECT *
-- FROM rating_rest_by_cuisine('Ranchi', 'Desserts');


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

-- CALL del_rest_cuisine('OMG Cafe', 'Ranchi', 'Desserts');

-- 'OMG Cafe', 'Ranchi', 'Desserts'
-- INSERT INTO restaurant_cuisine(restaurant_id, cuisine_id)
-- VALUES (3, 4);

-- SELECT *
-- FROM restaurant_cuisine
-- WHERE restaurant_id IN 
--      (SELECT restaurant_id
-- 		 FROM restaurant
-- 		 WHERE restaurant_name = 'OMG Cafe'
-- 		   AND city_id = (SELECT city_id
-- 						  FROM location
-- 						  WHERE city = 'Ranchi'))



DROP FUNCTION IF EXISTS check_and_insert_rating();
CREATE OR REPLACE FUNCTION check_and_insert_rating()
RETURNS TRIGGER 
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.rating < 0 OR NEW.rating > 5 THEN
    RAISE EXCEPTION 'Rating must be between 0 and 5';
  ELSE
    RETURN NEW;
  END IF;
END;
$$;

DROP TRIGGER IF EXISTS trigger_check_and_insert_rating ON restaurant;
CREATE TRIGGER trigger_check_and_insert_rating
AFTER INSERT OR UPDATE
ON restaurant
FOR EACH ROW
EXECUTE FUNCTION check_and_insert_rating();

-- INSERT INTO restaurant (restaurant_name, rating, city_id)
-- VALUES ('Puzata Hata', 5, 1);

-- SELECT *
-- FROM restaurant