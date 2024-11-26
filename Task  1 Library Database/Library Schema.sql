create schema library;
use library;

create table author 
(
	author_id int primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null
);


create table library_branch
(
	branch_id int primary key,
    state varchar(50),
    address varchar(200)
);

create table employee_department
(
	department_id int primary key,
    department varchar(50) not null unique
);

create table employee
(
	employee_id int auto_increment primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    age int not null,
    library_branch_id int not null,
    department_id int not null,
    hire_date date not null,
    foreign key emp_branch (library_branch_id)
		references library_branch (branch_id),
    foreign key emp_department (department_id)
		references employee_department (department_id)
);

create table book_category
(
	category_id int primary key,
    category varchar(50) not null unique
);

create table publisher
(
	publisher_id int primary key,
    publisher varchar(50) not null unique
);

create table book
(
	book_id int primary key,
    title varchar(200) not null,
    category_id int not null,
    publisher_id int not null,
    publication_date date not null,
    foreign key book_publisher (publisher_id)
		references publisher (publisher_id),
	foreign key book_category (category_id)
		references book_category (category_id)
);

create table book_author
(
	book_id int,
    author_id int,
    foreign key book_author_author (author_id)
		references author (author_id),
	foreign key book_author_book (book_id)
		references book (book_id)
);

create table `language`
(
	language_id int primary key,
    `language` varchar(50) not null unique
);

create table stock
(
	book_copy_id int auto_increment primary key,
    book_id int not null,
    branch_id int not null,
    language_id int not null,
    foreign key stock_book (book_id)
		references book (book_id),
	foreign key stock_branch (branch_id)
		references library_branch (branch_id),
	foreign key stock_language (language_id)
		references `language` (language_id)
);

create table `member`
(
	member_id int auto_increment primary key,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    age int not null,
    gender ENUM('M','F') not null,
    join_date date not null,
    membership_status ENUM('active','not active') not null
);

create table member_details
(
	member_id int not null,
    number_1 int not null,
    number_2 int,
    address varchar(250) not null unique,
    foreign key details_member (member_id)
		references `member` (member_id)
);

create table reservation
(
	reservation_id int auto_increment primary key,
    member_id int not null,
    book_id int not null,
    reservation_date date not null,
    foreign key reserve_member (member_id)
		references `member` (member_id),
	foreign key reserve_book (book_id)
		references book (book_id)
);

create table bank
(
	bank_id int primary key,
    bank_name varchar(50) not null unique
);

create table loan
(
	loan_id int auto_increment primary key,
    member_id int not null,
    book_copy_id int not null,
    amount decimal(10,2) not null,
    loan_date date not null,
    return_date date not null,
    transaction_type ENUM('cash','card'),
    bank_id int,
    foreign key loan_member (member_id)
		references `member` (member_id),
	foreign key loan_copy (book_copy_id)
		references stock (book_copy_id),
	foreign key loan_bank (bank_id)
		references bank (bank_id)
);

create table fine
(
	fine_id int auto_increment primary key,
    member_id int not null,
    loan_id int not null,
    fine_amount decimal(10,2) not null,
    fine_date date not null,
    `status` ENUM('paid','not paid') not null,
    foreign key fine_member (member_id)
		references `member` (member_id),
	foreign key fine_loan (loan_id)
		references loan (loan_id)
);

create table `transaction`
(
	transaction_id int auto_increment primary key,
    member_id int not null,
    loan_id int,
    fine_id int,
    `date` date not null,
    transcation_type ENUM('cash','card'),
    bank_id int,
    amount decimal(10,2) not null,
    foreign key tran_member (member_id)
		references `member` (member_id),
	foreign key tran_loan (loan_id)
		references loan (loan_id),
	foreign key tran_fine (fine_id)
		references fine (fine_id),
	foreign key tran_bank (bank_id)
		references bank (bank_id)
);


-- Triggers

delimiter //
create trigger loan_to_transaction
after insert on loan
for each row
begin 
	insert into `transaction` 
		(member_id, loan_id, `date`, transaction_type, bank_id, amount)
	values (new.member_id, new.loan_id, new.loan_date, new.transaction_type, new.bank_id, new.amount);
end //
delimiter ;

delimiter //
create trigger transaction_to_fine
after insert on `transaction`
for each row
begin 
	if new.fine_id is not null
		then
			update fine
            set `status` = 'paid'
            where fine_id = new.fine_id;
		end if;
    end //
delimiter ;

delimiter //
create event delete_expired_reservations
on schedule every 1 day
do
begin
	delete
    from reservation
    where reservation_date < curdate();
end //
delimiter ;
