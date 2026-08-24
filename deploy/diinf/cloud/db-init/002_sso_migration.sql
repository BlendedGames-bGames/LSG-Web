-- SSO Migration: Add lsg_user_id column for LifeSync Games SSO bridge
-- This column stores the UUIDv4 from the Auth Service JWT `sub` claim
-- Used for identity mapping between LSG platform and cloud module players

ALTER TABLE playerss ADD COLUMN lsg_user_id VARCHAR(36) UNIQUE DEFAULT NULL;

-- Make id_players auto-increment for new player creation via SSO
-- NO_AUTO_VALUE_ON_ZERO is needed because existing data has id_players=0
SET @@SESSION.sql_mode = CONCAT(@@SESSION.sql_mode, ',NO_AUTO_VALUE_ON_ZERO');
ALTER TABLE playerss MODIFY id_players INT NOT NULL AUTO_INCREMENT;
