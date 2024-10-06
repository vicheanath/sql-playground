
/* CREATE TABLE [dbo].[Employees](

	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,

	[FullName] [nvarchar](250) NOT NULL,

	[DeptID] [int] NULL,

	[Salary] [int] NULL,

	[HireDate] [date] NULL,

	[ManagerID] [int] NULL

) ;
*/



-- Emplyee With highest salary in a department

SELECT Emp.EmployeeID, Emp.DeptID, Salary
FROM Employees Emp
INNER JOIN (
	SELECT 
		DeptID,
		MAX(Salary) as MaxSalary
	FROM [Employees]
	GROUP BY DeptID
	) as Emp1
ON Emp.DeptID = Emp1.DeptID
AND Emp.Salary = Emp1.MaxSalary

-- Other way
SELECT Emp.EmployeeID, Emp.DeptID, Emp.Salary
FROM ( 
	SELECT 
		EmployeeID,
		DeptID,
		Salary,
		RANK() OVER (PARTITION BY DEPTID ORDER BY SALARY DESC) AS SAL
FROM Employees) as Emp
WHERE SAL = 1

-- Find Employees with salary lesser then department average
SELECT Emp.EmployeeID, Emp.DeptID, Salary
FROM Employees Emp
INNER JOIN (
	SELECT 
		DeptID,
		AVG(Salary) as AVGSalary
	FROM [Employees]
	GROUP BY DeptID
	) as Emp1
ON Emp.DeptID = Emp1.DeptID
AND Emp.Salary < Emp1.AVGSalary


-- Find Employee with salary lesser then dept average but more then average of ANY other Depts
SELECT Emp.EmployeeID, Emp.DeptID, Salary
FROM Employees Emp
INNER JOIN (
	SELECT 
		DeptID,
		AVG(Salary) as AVGSalary
	FROM [Employees]
	GROUP BY DeptID
	) as Emp1
ON Emp.DeptID = Emp1.DeptID
AND Emp.Salary < Emp1.AVGSalary
AND Emp.Salary > ANY (
	SELECT AVG(Salary) 
	FROM Employees 
	GROUP BY DeptID
)

-- Find Employee With The Same Slary
SELECT Emp1.*
FROM Employees Emp1
INNER JOIN Employees Emp2
ON Emp1.Salary = Emp2.Salary
WHERE Emp1.EmployeeID <> Emp2.EmployeeID

-- Dept where none of the employees has salary greater then their manager's salary
SELECT DISTINCT DeptID
FROM Employees
WHERE DeptID NOT IN (
	SELECT Emp.DeptID
	FROM Employees Emp
	INNER JOIN Employees Mgr
	ON Emp.ManagerID = Mgr.EmployeeID
	WHERE Emp.Salary > Mgr.Salary
)

-- Diff between employee salary and average salary of department
SELECT EmployeeID, DeptID ,Salary, Salary - AVG(Salary) OVER (PARTITION BY DEPTID) AS DIFFSAL
FROM Employees

-- Find Employee whose salary is in top 2 percentile in department
SELECT EmployeeID, Salary
FROM (
	SELECT EmployeeID, Salary, DeptID,
		PERCENT_RANK() OVER (PARTITION BY DEPTID ORDER BY SALARY) as RK
	FROM Employees
) as Emp
WHERE RK >= 0.98

-- Find Employee who earn more than every employee in dept no 2
SELECT EmployeeID, Salary
FROM Employees
WHERE Salary > ALL (
	SELECT MAX(Salary) FROM Employees 
	WHERE DeptID = 2
)
