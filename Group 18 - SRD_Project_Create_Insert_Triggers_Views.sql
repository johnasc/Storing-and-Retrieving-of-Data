# Project Description
# V Magazine is a Small Store with 2 units in Lisbon and 1 unit in Spain that sells clothes and shoes for men, women and children.
# The costumers are locals or tourists that come from diverse countries.
# For the analysis, the data used is a sample from 2 sales period, in the last week of september (Fall Week) and in the last week of november (Black Week) in 2021 and 2022.
# A Trigger was created to advertise for changes in stock, so the supplier can be contacted.
# Triggers where created to add changes in a log table

-- -----------------------------------------------------
-- Schema vmagazine_sales
-- -----------------------------------------------------

DROP SCHEMA IF EXISTS vmagazine_sales;

CREATE SCHEMA IF NOT EXISTS `vmagazine_sales` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `vmagazine_sales` ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`log`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`log` (
  `LogId`  INT NOT NULL AUTO_INCREMENT,
  `UpdateTime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `User` VARCHAR(50) NULL DEFAULT NULL,
  `Event` VARCHAR(20) NULL DEFAULT NULL,
  `Description` VARCHAR(100) NULL DEFAULT NULL,
  PRIMARY KEY (`LogId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`country`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`country` (
  `CountryId` INT NOT NULL,
  `CountryName` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`CountryId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Country_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`country`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add country", new.CountryName);
END $$

CREATE TRIGGER `Country_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`country`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete country", old.CountryName);
END $$
DELIMITER ;

-- -----------------------------------------------------
-- Table `vmagazine_sales`.`city`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`city` (
  `CityId` INT NOT NULL,
  `CityName` VARCHAR(30) NULL DEFAULT NULL,
  `CountryId` INT NULL DEFAULT NULL,
  PRIMARY KEY (`CityId`),
  INDEX `fk_City_1` (`CityId` ASC) VISIBLE,
  CONSTRAINT `fk_City_11`
	FOREIGN KEY (`CountryId`)
    REFERENCES `vmagazine_sales`.`country` (`CountryId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;

DELIMITER $$
CREATE TRIGGER `city_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`city`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add city", new.cityName);
END $$

CREATE TRIGGER `city_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`city`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete city", old.cityName);
END $$
DELIMITER ;

-- -----------------------------------------------------
-- Table `vmagazine_sales`.`address`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`address` (
  `AddressId` INT NOT NULL,
  `Address` VARCHAR(50) NOT NULL,
  `Postal Code` VARCHAR(10) NULL,
  `CityId` INT NULL DEFAULT NULL,
  PRIMARY KEY (`AddressId`),
  INDEX `fk_Address_1` (`CityId` ASC) VISIBLE,
  CONSTRAINT `fk_Address_1`
	FOREIGN KEY (`CityId`)
    REFERENCES `vmagazine_sales`.`city` (`CityId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Address_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`address`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add address", concat(new.Address,' ', new.`Postal Code`));
END $$

CREATE TRIGGER `Address_AfterUpdate_Log`
AFTER UPDATE
ON `vmagazine_sales`.`address`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "update address", concat(old.Address,' ', old.`Postal Code`," changed to ", new.Address,' ', new.`Postal Code`));
END $$

CREATE TRIGGER `Address_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`address`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete address", concat(old.Address,' ', old.`Postal Code`));
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`customer`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`customer` (
  `CustomerId` INT NOT NULL,
  `FirstName` VARCHAR(50) NOT NULL,
  `LastName` VARCHAR(50) NULL DEFAULT NULL,
  `Gender` CHAR(1) NULL DEFAULT NULL,
  `DOB` DATE NULL DEFAULT NULL,
  `Mobile` VARCHAR(20) NULL DEFAULT NULL,
  `AddressId` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`CustomerId`),
  INDEX `fk_Customer_1` (`AddressId` ASC) VISIBLE,
  CONSTRAINT `fk_Customer_1`
    FOREIGN KEY (`AddressId`)
    REFERENCES `vmagazine_sales`.`address` (`AddressId`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Customer_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`customer`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add customer", concat(new.FirstName,' ', new.LastName));
END $$

CREATE TRIGGER `Customer_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`customer`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete customer", concat(old.FirstName,' ', old.LastName));
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`role`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`role` (
  `RoleId` INT NOT NULL,
  `RoleName` VARCHAR(30) NOT NULL,
  `RoleDesc` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`RoleId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Role_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`role`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add role", new.RoleName);
END $$

CREATE TRIGGER `Role_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`role`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete role", old.RoleName);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`store`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`store` (
  `StoreId` INT NOT NULL,
  `StoreName` VARCHAR(30) NOT NULL,
  `AddressId` INT NOT NULL,
  PRIMARY KEY (`StoreId`),
  INDEX `fk_Store_1` (`AddressId` ASC) VISIBLE,
  CONSTRAINT `fk_Store_1`
    FOREIGN KEY (`AddressId`)
    REFERENCES `vmagazine_sales`.`address` (`AddressId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Store_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`store`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add store", new.StoreId);
END $$

CREATE TRIGGER `Store_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`store`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete store", old.StoreId);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`employee`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`employee` (
  `EmployeeID` INT NOT NULL,
  `EmployeeFirstName` VARCHAR(50) NOT NULL,
  `EmployeeLastName` VARCHAR(50) NULL DEFAULT NULL,
  `Gender` CHAR(1) NULL DEFAULT NULL,
  `PhoneNumber` VARCHAR(25) NULL DEFAULT NULL,
  `RoleId` INT NOT NULL,
  `StoreId` INT NOT NULL,
  PRIMARY KEY (`EmployeeID`),
  INDEX `fk_Employee_role1_idx` (`RoleId` ASC) VISIBLE,
  INDEX `fk_Employee_store1_idx` (`StoreId` ASC) VISIBLE,
  CONSTRAINT `fk_Employee_role1`
    FOREIGN KEY (`RoleId`)
    REFERENCES `vmagazine_sales`.`role` (`RoleId`),
  CONSTRAINT `fk_Employee_store1`
    FOREIGN KEY (`StoreId`)
    REFERENCES `vmagazine_sales`.`store` (`StoreId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Employee_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`employee`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add employee", concat(new.EmployeeFirstName,' ', new.EmployeeLastName));
END $$

CREATE TRIGGER `Employee_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`employee`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete employee", concat(old.EmployeeFirstName,' ', old.EmployeeLastName));
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`product_category`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`product_category` (
  `ProdCatId` INT NOT NULL,
  `ProdCatName` VARCHAR(50) NOT NULL,
  `ProdCatDesc` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`ProdCatId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `ProdCat_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`product_category`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add prod cat", new.ProdCatName);
END $$

CREATE TRIGGER `ProdCat_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`product_category`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete prod cat", old.ProdCatName);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`product` (
  `ProdId` INT NOT NULL,
  `ProdName` VARCHAR(50) NOT NULL,
  `ProdDesc` VARCHAR(50) NULL DEFAULT NULL,
  `ProdCatId` INT NULL DEFAULT NULL,
  `ProdPrice` DECIMAL(5,2) NOT NULL,
  PRIMARY KEY (`ProdId`),
  INDEX `fk_Product_1` (`ProdCatId` ASC) VISIBLE,
  CONSTRAINT `fk_Product_1`
    FOREIGN KEY (`ProdCatId`)
    REFERENCES `vmagazine_sales`.`product_category` (`ProdCatId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Product_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`product`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add product", new.ProdName);
END $$

CREATE TRIGGER `Product_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`product`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete product", old.ProdName);
END $$
DELIMITER ;

-- -----------------------------------------------------
-- Table `vmagazine_sales`.`inventory`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`inventory` (
  `InventoryId` INT NOT NULL AUTO_INCREMENT,
  `ProdId` INT NOT NULL,
  `StoreId` INT NOT NULL,
  `QuantityOnHand` INT NOT NULL DEFAULT '0',
  PRIMARY KEY (`InventoryId`),
  INDEX `fk_Inventory_1` (`ProdId` ASC) VISIBLE,
  INDEX `fk_Inventory_2` (`StoreId` ASC) VISIBLE,
  CONSTRAINT `fk_Inventory_1`
    FOREIGN KEY (`ProdId`)
    REFERENCES `vmagazine_sales`.`product` (`ProdId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Inventory_2`
    FOREIGN KEY (`StoreId`)
    REFERENCES `vmagazine_sales`.`store` (`StoreId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Inventory_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`inventory`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add inventory", new.InventoryId);
END $$

CREATE TRIGGER `Inventory_AfterUpdate_Log`
AFTER UPDATE
ON `vmagazine_sales`.`inventory`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "update inventory", concat(new.ProdId, ' had ', old.QuantityOnHand," and changed to ", new.QuantityOnHand, ' at store', new.StoreId));
END $$

CREATE TRIGGER `Inventory_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`inventory`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete inventory", old.InventoryId);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`payment_method`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`payment_method` (
  `PmtMethodId` INT NOT NULL AUTO_INCREMENT,
  `PmntMethodName` VARCHAR(20) NOT NULL,
  PRIMARY KEY (`PmtMethodId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `PayMethod_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`payment_method`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add pay method", new.PmntMethodName);
END $$

CREATE TRIGGER `PayMethod_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`payment_method`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete pay method", old.PmntMethodName);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`promotion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`promotion` (
  `PromoId` INT NOT NULL AUTO_INCREMENT,
  `PromoName` VARCHAR(30) NOT NULL,
  `PromoPercentage` DECIMAL(4,2) NOT NULL,
  PRIMARY KEY (`PromoId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Promotion_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`promotion`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add promotion", new.PromoName);
END $$
CREATE TRIGGER `Promotion_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`promotion`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete promotion", old.PromoName);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`order`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`order` (
  `OrderId` INT NOT NULL AUTO_INCREMENT,
  `CustomerId` INT NOT NULL,
  `PmtMethodId` INT NOT NULL,
  `PromoId` INT NOT NULL DEFAULT 9,
  `StoreId` INT NOT NULL,
  `CreateDate` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Rating` INT NULL DEFAULT NULL,
  PRIMARY KEY (`OrderId`),
  INDEX `fk_order_1` (`CustomerId` ASC) VISIBLE,
  INDEX `fk_order_2` (`PmtMethodId` ASC) VISIBLE,
  INDEX `fk_order_3` (`PromoId` ASC) VISIBLE,
  INDEX `fk_order_4` (`StoreId` ASC) VISIBLE,
  CONSTRAINT `fk_order_1`
    FOREIGN KEY (`CustomerId`)
    REFERENCES `vmagazine_sales`.`customer` (`CustomerId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_order_2`
    FOREIGN KEY (`PmtMethodId`)
    REFERENCES `vmagazine_sales`.`payment_method` (`PmtMethodId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_order_3`
    FOREIGN KEY (`PromoId`)
    REFERENCES `vmagazine_sales`.`promotion` (`PromoId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_order_4`
    FOREIGN KEY (`StoreId`)
    REFERENCES `vmagazine_sales`.`store` (`StoreId`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `Order_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`order`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add order", new.OrderId);
END $$

CREATE TRIGGER `Order_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`order`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete order", old.OrderId);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Table `vmagazine_sales`.`order_itens`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `vmagazine_sales`.`order_itens` (
  `OrderItensId` INT NOT NULL AUTO_INCREMENT,
  `OrderId` INT NOT NULL,
  `ProdId` INT NOT NULL,
  `Quantity` INT NOT NULL,
  PRIMARY KEY (`OrderItensId`),
  INDEX `fk_order_itens_transaction_idx` (`OrderId` ASC) VISIBLE,
  INDEX `fk_order_itens_product1_idx` (`ProdId` ASC) VISIBLE,
  CONSTRAINT `fk_order_itens_1`
    FOREIGN KEY (`OrderId`)
    REFERENCES `vmagazine_sales`.`order` (`OrderId`),
  CONSTRAINT `fk_order_itens_2`
    FOREIGN KEY (`ProdId`)
    REFERENCES `vmagazine_sales`.`product` (`ProdId`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


DELIMITER $$
CREATE TRIGGER `OrderItens_AfterInsert_Log`
AFTER INSERT
ON `vmagazine_sales`.`order_itens`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "add order itens", new.OrderItensId);
END $$

CREATE TRIGGER `OrderItens_BeforeDelete_Log`
BEFORE DELETE
ON `vmagazine_sales`.`order_itens`
FOR EACH ROW
BEGIN
	INSERT `vmagazine_sales`.`log` (`User`, `Event`, `Description`) Values
		(user(), "delete order itens", old.OrderItensId);
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Triggers Update Inventory
-- -----------------------------------------------------
DELIMITER $$
CREATE TRIGGER `OrderItens_AfterInsert_Inventory`
AFTER INSERT
ON `vmagazine_sales`.`order_itens`
FOR EACH ROW
BEGIN
	SELECT `vmagazine_sales`.`order`.`StoreId` INTO @S
		FROM `vmagazine_sales`.`order`
        JOIN `vmagazine_sales`.`order_itens`
        ON `vmagazine_sales`.`order`.`OrderId`= `vmagazine_sales`.`order_itens`.`OrderId`
			WHERE `vmagazine_sales`.`order`.`OrderId` = new.OrderId LIMIT 1;
        
	UPDATE `vmagazine_sales`.`inventory`
		SET `vmagazine_sales`.`inventory`.`QuantityOnHand` = `vmagazine_sales`.`inventory`.`QuantityOnHand` - new.Quantity
			WHERE `vmagazine_sales`.`inventory`.`ProdId` = new.`ProdId`
            AND `vmagazine_sales`.`inventory`.`StoreId` = @S;
END $$
DELIMITER ;


-- -----------------------------------------------------
-- Insertions
-- -----------------------------------------------------
INSERT INTO `vmagazine_sales`.`country` VALUES
	(1, 'Portugal'), 
    (2, 'Spain'), 
    (3, 'France'), 
    (4, 'Turkey'), 
    (5, 'Italy'), 
    (6, 'Malaysia'), 
    (7, 'England'), 
    (8, 'Germany'), 
    (9, 'Switzerland'),
    (0, 'Not Defined');
    
  
INSERT INTO `vmagazine_sales`.`city` VALUES
(11,'Lisbon',1),
(12,'Coimbra',1),
(21,'Madrid',2),
(31,'Paris',3),
(41,'Istanbul',4),
(51,'Rome',5),
(61,'Kuala Lumpar',6),
(71,'London',7),
(72,'Liverpool',7),
(81,'Potsdam',8),
(82,'Berlin',8),
(91,'Pollen',9),
(0, 'Not defined', 0);

INSERT INTO `vmagazine_sales`.`address` VALUES
 	(1001, 'Av. Doutor Miguel Bombarda, no6', '2710-590', 11),
    (1002, 'Rua Vasco da Gama 31', '2670-000', 11),
    (1003, 'Calle Nieremberg, 51', '28473', 21),
    (1004, 'Calle de Pelayo, 25', '28933', 21),
    (1005, 'Karabulut mahallesi, Cankaya', '54000', 41),
    (1006, 'Rua mar da cabeca, Lisabon', '19900', 11),
    (1007, 'Casana, Rome' ,'18900', 51), 
    (1008, 'Mahabat kachori, Kuala Lumpar', '54040', 61), 
    (1009, 'American street, Perth' ,'54050', 71), 
    (1010, 'Rua pedro monteiro, Coimbra', '54000', 12), 
    (1011, 'Shengo street, Dodoma', '54400', 72), 
    (1012, 'Postman stranze, Potsdam', '23000', 81), 
    (1013, 'Karabulut mahallesi, Cankayaaa' ,'400-12', 41), 
    (1014, 'Leceé, Rome', '23000', 51), 
    (1015, 'Rua mar da cabeca, Lisbon', '1000', 11), 
    (1016, 'Rua madagascar, Paris', '54000', 31), 
    (1017, 'St Pollen, Suisse', '14000', 91), 
    (1018, 'Lysee stranze, Berlin', '20000', 82),
    (0, 'Not Defined', 'None', 0);

INSERT INTO `vmagazine_sales`.`customer` VALUES
	(100001, 'Megan', 'Beasley', 'F', '1999-01-01', '351987654321', 1004),
	(100002, 'Can', 'Ozdemir', 'M', '1992-12-13', '90897456989', 1005), 
	(100003, 'Cansu', 'Ozdemir', 'F', '1994-11-19', '90897888990', 1005), 
	(100004, 'Rosana', 'Mendes', 'F', '1992-12-11', '35100234567', 1006), 
	(100005, 'Janama', 'Samuel', 'F', '1982-02-03', '39097456989', 1007), 
	(100006, 'Camila', 'Emanuel', 'F', '1962-02-23', '98900908772', 1008), 
	(100007, 'Kizomba', 'Bachata', 'F', '1982-10-11', '480987654321', 1009), 
	(100008, 'Can', 'Ozdemir', 'F', '1990-02-11', '35189456989', 1010), 
	(100009, 'Sema', 'Ozan', 'F', '1990-12-03', '2554556989', 1011), 
	(100010, 'Laila', 'Omar', 'F', '1990-12-11', '351932438788', 1006), 
	(100011, 'Leonie', 'Nuich', 'F', '1972-09-04', '49675804585', 1012), 
	(100012, 'Esma', 'Mahmut', 'F', '1975-12-12', '90897452222', 1012), 
	(100013, 'Pamela', 'Oreo', 'F', '1969-11-04', '39898978786', 1015), 
	(100014, 'Lamba', 'Lombo', 'F', '1978-10-22', '6878787897', 1013), 
	(100015, 'Josh', 'McDonald', 'M', '1978-05-08', '447678987675', 1014), 
	(100016, 'Yusuf', 'Bulut', 'M', '1999-07-09', '9089222333', 1014), 
	(100017, 'Bruno', 'Mendes', 'M', '1992-01-11', '50737377373', 1016), 
	(100018, 'Rui', 'Costa', 'M', '1989-04-27', '3511456989', 1006), 
	(100019, 'Antonie', 'Griezmann', 'M', '1977-06-28', '334444444332', 1018), 
	(100020, 'Granit', 'Xhaka', 'M', '1974-03-29', '357737392733', 1017), 
	(100021, 'Miroslav', 'Klose', 'M', '1987-08-30', '4974563829474', 1018),
    (0, 'Not Defined', NULL, NULL, NULL, NULL, 0);
    
INSERT INTO `vmagazine_sales`.`role` VALUES
    (1, 'Manager', 'Controls Inventory and Employee Management'),
	(2, 'Salesperson', 'Helps customers and sells');

INSERT INTO `vmagazine_sales`.`store` VALUES
	(1, 'V Magazine - Pink Store',1001),
    (2, 'V Magazine - Black Store',1002),
    (3, 'V Magazine - Red Store', 1003);

INSERT INTO `vmagazine_sales`.`employee` VALUES
 	(11001, 'Jorge', 'Ramos', 'M', '351786799000', 1, 1),
 	(11002, 'Johanna', 'Teixeira', 'F', '351786888453', 2, 1),
 	(11003, 'Peter', 'Offy', 'M', '351770990123', 2, 1),
 	(11004, 'Maria', 'Handoly', 'F', '351559085333', 2, 1),
    (11005, 'Antonio', 'Campos', 'M', '351123789456', 2, 1),
    (11006, 'Julia', 'Gomes', 'F', '351230847547', 1, 2),
    (11007, 'Gabriel', 'Silveira', 'M', '351763843847', 2, 2),
    (11008, 'Pietra', 'Oliveira', 'F', '351203859734', 2, 2),
    (11009, 'Diego', 'Fernandes', 'M', '351573484283',2, 2),
    (11010, 'Maria', 'Viana', 'F', '351028547456', 1, 3),
    (11011, 'Stella', 'Dias', 'F', '351453870392', 2, 3),
    (11012, 'Maysa', 'Lima', 'F', '351835279203', 2, 3);

INSERT INTO `vmagazine_sales`.`product_category` VALUES
	(1, 'Men', 'Products for men only'),
	(2, 'Women', 'Products for women only'),
	(3, 'Children', 'Products for children only');

INSERT INTO `vmagazine_sales`.`product` VALUES
	(100001, 'White Sneakers', 'Model X Size 40', 1, 250.00),
    (100002, 'White Sneakers', 'Model X Size 42', 1, 250.00),
    (100003, 'Blue Jeans', 'Model Classic Size 36', 1, 29.90),
    (100004, 'Blue Jeans', 'Model Skinny Size 36', 1, 39.90),
    (100005, 'Red T-shirt', 'Model A Size M', 1, 15.00),
    (100006, 'Black T-shirt', 'Model A Size M', 1, 15.00),
    (100007, 'Blue Shirt', 'Model M Size M', 1, 25.00),
    (100008, 'Black Tie', 'Plain Black', 1, 5.00),
    (100009, 'Underwear', 'Boxers', 1, 2.00),
    (100010, 'Socks', 'Sizes 38 - 44', 1, 1.50),
    (200001, 'High Heels', 'Model X Size 38', 2, 150.00),
    (200002, 'Red Sneakers', 'Model Y Size 38', 2, 250.00),
    (200003, 'Black Jeans', 'Model Classic Size 36', 2, 29.90),
    (200004, 'Black Jeans', 'Model Skinny Size 36', 2, 39.90),
    (200005, 'Red Dress', 'Model A Size M', 2, 39.90),
    (200006, 'White Blazer', 'Model B Size M', 2, 49.90),
    (200007, 'Blue Shirt', 'Model F Size M', 2, 15.00),
    (200008, 'Basic Shirt', 'Plain Black', 2, 9.90),
    (200009, 'Underwear', 'Panties', 2, 2.00),
    (200010, 'Socks', 'Sizes 34 - 40', 2, 1.00),
    (300001, 'Toy Story Shirt', 'Toy Story T-shirt Size S', 3, 9.90),
    (300002, 'Bermudas', 'Bermudas Size M', 3, 12.00),
    (300003, 'Sandals', 'Havaianas Size 28', 3, 19.90);

INSERT INTO `vmagazine_sales`.`inventory` (`ProdId`, `StoreId`, `QuantityOnHand`) VALUES
	(100001, 1, 20), (100001, 2, 10), (100001, 3, 3),
    (100002, 1, 15), (100002, 2, 18), (100002, 3, 0),
    (100003, 1, 10), (100003, 2, 4), (100003, 3, 15),
    (100004, 1, 12), (100004, 2, 13), (100004, 3, 2),
    (100005, 1, 9), (100005, 2, 25), (100005, 3, 8),
    (100006, 1, 5), (100006, 2, 2), (100006, 3, 15),
    (100007, 1, 15), (100007, 2, 5), (100007, 3, 2),
    (100008, 1, 1), (100008, 2, 15), (100008, 3, 1),
    (100009, 1, 0), (100009, 2, 8), (100009, 3, 0),
    (100010, 1, 25), (100010, 2, 7), (100010, 3, 15),
    (200001, 1, 12), (200001, 2, 10), (200001, 3, 15),
    (200002, 1, 8), (200002, 2, 5), (200002, 3, 13),
    (200003, 1, 14), (200003, 2, 10), (200003, 3, 2),
    (200004, 1, 13), (200004, 2, 17), (200004, 3, 14),
    (200005, 1, 7), (200005, 2, 20), (200005, 3, 5),
    (200006, 1, 4), (200006, 2, 2), (200006, 3, 4),
    (200007, 1, 0), (200007, 2, 0), (200007, 3, 30),
    (200008, 1, 15), (200008, 2, 5), (200008, 3, 0),
    (200009, 1, 17), (200009, 2, 5), (200009, 3, 3),
    (200010, 1, 9), (200010, 2, 20), (200010, 3, 0),
    (300001, 1, 10), (300001, 2, 8), (300001, 3, 5),
    (300002, 1, 10), (300002, 2, 2), (300002, 3, 15),
    (300003, 1, 10), (300003, 2, 2), (300003, 3, 25);


INSERT INTO `vmagazine_sales`.`payment_method` (`PmntMethodName`) VALUES
	('Cash'), ('Credit Card'), ('Debit Card'), ('MBWAY'), ('PayPal');

INSERT INTO `vmagazine_sales`.`promotion` (`PromoId`,`PromoName`, `PromoPercentage`) VALUES
	(9,'No Sale', 00.00),
    (1,'Christmas', 30.00),
	(2,'Black Week', 20.00),
    (3,'Fall Week', 10.00);

INSERT INTO `vmagazine_sales`.`order` (`CustomerId`, `PmtMethodId`, `PromoId`, `StoreId`, `Rating`,`CreateDate`) VALUES
(100001,1,3,1,5,'2021-09-25'),
(100002,2,3,2,4,'2021-09-25'),
(100003,2,3,3,NULL,'2021-09-25'),
(100004,3,3,1,3,'2021-09-25'),
(100005,1,3,1,5,'2021-09-25'),
(100006,2,2,1,4,'2021-11-25'),
(100007,2,2,2,1,'2021-11-25'),
(100008,3,2,2,4,'2021-11-25'),
(100009,4,2,3,3,'2021-11-25'),
(100010,1,2,1,NULL,'2021-11-25'),
(100011,1,2,1,3,'2021-11-25'),
(100012,1,2,3,2,'2021-11-25'),
(100013,2,3,1,NULL,'2022-09-25'),
(100014,2,3,1,5,'2022-09-25'),
(100015,3,3,3,2,'2022-09-25'),
(100016,4,3,2,3,'2022-09-25'),
(100017,5,3,2,4,'2022-09-25'),
(100018,1,2,2,NULL,'2022-11-25'),
(100019,3,2,2,4,'2022-11-25'),
(100020,1,2,1,5,'2022-11-25'),
(100021,1,2,1,NULL,'2022-11-25');



INSERT INTO `vmagazine_sales`.`order_itens` (`OrderId`, `ProdId`, `Quantity`) VALUES
	(1, 200001, 1), (1, 200003, 2), (1, 200005, 4),
    (2, 100001, 1), (2, 100003, 1),
    (3, 200005, 1),
    (4, 300001, 1),
    (5, 100001, 1),
    (6, 100001, 2),
    (7, 300003, 1),
    (8, 100001, 1),
    (9, 100005, 1),
    (10, 100001, 1),
    (11, 100001, 1),
    (12, 200006, 3),
    (13, 100001, 1),
    (14, 100001, 1),
    (15, 300003, 1),
    (16, 100001, 2),
    (17, 100005, 1),
    (18, 100001, 1),
    (19, 100001, 1),
    (20, 200006, 2),
    (21, 100001, 1);
    
-- -----------------------------------------------------
-- Demonstration of Triggers
-- -----------------------------------------------------
# We want to show that inventory is updated whenever the customer makes a purchase
# Checking the current inventory
# SELECT * FROM `vmagazine_sales`.`inventory`;

# From this table, we can check that product 100001 at Store 1 has 12 itens on stock
# We are creating a generic order at store 1
# INSERT INTO `vmagazine_sales`.`order` (`CustomerId`, `PmtMethodId`, `PromoId`, `StoreId`, `Rating`,`CreateDate`)
#	VALUES (100001,1,9, 1, NULL, CURRENT_DATE);

# Now let's check the new order and its OrderId
# SELECT * FROM `vmagazine_sales`.`order` ORDER BY OrderId DESC LIMIT 1;
 
# From the previous select, we can check the OrderId is 22
# Let's create a transaction for ProdId 100001 of 3 itens
# INSERT INTO `vmagazine_sales`.`order_itens` (`OrderId`, `ProdId`, `Quantity`) 
# 	VALUES (22, '100001', 3); 

# Now, let's confirm the Inventory for Product 100001 at Store 1
# SELECT * FROM `vmagazine_sales`.`inventory`
# 	WHERE ProdId = 100001 AND StoreId = 1;

# We confirm the Inventory was updated

# Now let's check the changes in the Log table
# SELECT * FROM `vmagazine_sales`.`log`
# 	ORDER BY LogId DESC LIMIT 3;

-- -----------------------------------------------------
-- Invoice Views
-- -----------------------------------------------------

#View for the head and totals

create view invoice_head as
select 
o.Orderid as 'Invoice Number',
concat(c.FirstName,' ',c.LastName) as 'Client Name',
concat(ac.Address,',',cic.CityName,',',coc.CountryName) as 'Client Street Adress',
c.Mobile as 'Client Phone Number',
s.StoreName as 'Store',
coalesce(pr.PromoName,'No Promotion') as 'Promotion',
o.CreateDate as 'Invoice Date',
sum(oi.Quantity) 'Invoice Total (Itens)',
round(sum(oi.Quantity*p.ProdPrice*(1-(pr.PromoPercentage/100))),2) 'Invoice Total (Price - Euro)'
from customer c
join `order` o on o.CustomerId=c.CustomerId
join `order_itens` oi on oi.OrderId=o.OrderId
join Product p on p.ProdId=oi.ProdId
join store s on s.Storeid=o.StoreId
join address a on a.AddressId=s.AddressId
join city ci on ci.Cityid=a.Cityid
join country co on co.CountryId = ci.CountryId
join address ac on ac.AddressId=c.AddressId
join city cic on cic.Cityid=ac.Cityid
join country coc on coc.CountryId = cic.CountryId
join promotion pr on pr.PromoId=o.PromoId
group by o.OrderId
order by o.Orderid;


#View for the details

create view invoice_details as
select 
o.Orderid as 'Invoice Number',
p.ProdName as 'Product Name',
p.ProdDesc as 'Product Description',
p.ProdPrice as 'Unit Cost',
oi.Quantity as 'Product Quantity',
oi.Quantity*p.ProdPrice 'Total (Euro)',
pr.PromoPercentage as 'Discount Percentage',
round(oi.Quantity*p.ProdPrice*(1-(pr.PromoPercentage/100)),2) 'Total After Discount (Euro)'
from `order` o 
join `order_itens` oi on oi.OrderId=o.OrderId
join Product p on p.ProdId=oi.ProdId
join store s on s.Storeid=o.StoreId
join address a on a.AddressId=s.AddressId
join city ci on ci.Cityid=a.Cityid
join country co on co.CountryId = ci.CountryId
join promotion pr on pr.PromoId=o.PromoId
order by o.Orderid,oi.OrderItensId;