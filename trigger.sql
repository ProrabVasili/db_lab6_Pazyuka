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

CREATE TRIGGER trigger_check_and_insert_rating
AFTER INSERT OR UPDATE
ON restaurant
FOR EACH ROW
EXECUTE FUNCTION check_and_insert_rating();

-- INSERT INTO restaurant (restaurant_name, rating, city_id)
-- VALUES ('Puzata Hata', 5, 1);

-- SELECT *
-- FROM restaurant


