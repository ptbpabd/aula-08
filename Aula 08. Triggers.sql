-- Slide 5
CREATE TRIGGER setnull_trigger_takes
ON dbo.takes
AFTER INSERT AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
IF EXISTS (SELECT 1  
           FROM inserted AS i   
           JOIN dbo.takes AS v   
           ON v.ID = i.ID AND v.course_id = i.course_id AND v.sec_id = i.sec_id AND v.semester = i.semester AND v.[year] = i.[year]
           WHERE v.grade = ''  
          )  
BEGIN  
RAISERROR ('A grade can not be blank.', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;  

-- Tenta inserir o grade em branco
INSERT INTO takes (ID, course_id, sec_id, semester, [year], grade) VALUES (1018, 493, 1, 'Spring', 2010, '');

-- Slide 05
-- Trigger que atualiza o valor de créditos de um aluno após a realização de um curso
CREATE TRIGGER dbo.credits_earned
ON dbo.takes
AFTER INSERT AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
BEGIN
	UPDATE dbo.student
    SET tot_cred = tot_cred + (SELECT credits FROM dbo.course INNER JOIN inserted ON course.course_id = inserted.course_id) 
    WHERE student.id = (SELECT DISTINCT ID FROM inserted);	
END

SELECT ID, count(*) AS qtd_courses FROM takes 
GROUP BY ID
ORDER BY qtd_courses;

-- O estudante selecionado será '30299'
SELECT * FROM takes t WHERE t.ID = '30299' ORDER BY t.course_id;

-- A seção disponível e que será adicionada ao aluno é '105'
SELECT course_id, sec_id, semester, [year], building, room_number, time_slot_id FROM [section] WHERE course_id = '105';

-- O curso que será adicionado ao aluno é o '105' e possui 3 créditos
SELECT course_id, title, dept_name, credits FROM course WHERE course_id = '105' ORDER BY course_id;

-- Atualmente o aluno possui 38 créditos
SELECT ID, name, dept_name, tot_cred FROM student WHERE ID = '30299';

-- Após a inserção o aluno possuirá 41 créditos, pois a trigger será acionada
INSERT INTO takes (ID, course_id, sec_id, semester, [year], grade) VALUES ('30299', '105', '1', 'Fall', 2009, 'A+');

-- Slide 6
-- Relação de notas do aluno '30299'
SELECT * FROM takes t WHERE t.ID = '30299' ORDER BY t.course_id;

-- Trigger impedirá a atualização do grade do aluno
CREATE TRIGGER dbo.trigger_prevent_change_takes
ON dbo.takes
AFTER UPDATE AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
IF EXISTS (SELECT 1  
           FROM deleted AS d   
           JOIN dbo.takes AS v   
           ON v.ID = d.ID AND v.course_id = d.course_id AND v.sec_id = d.sec_id AND v.semester = d.semester AND v.[year] = d.[year] AND v.grade != d.grade
          )  
BEGIN  
RAISERROR ('A grade can not be update.', 16, 1);  
ROLLBACK TRANSACTION;  
RETURN   
END;

-- Tentativa de atualização da nota
UPDATE takes
SET grade = 'A+'
WHERE ID = '30299' AND course_id = '105' AND sec_id = '1' AND semester = 'Fall' AND [year]= 2009;


