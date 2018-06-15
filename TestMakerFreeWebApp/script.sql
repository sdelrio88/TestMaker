DECLARE @var0 sysname;
SELECT @var0 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'Flags');
IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var0 + '];');
ALTER TABLE [Users] DROP COLUMN [Flags];

GO

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'Notes');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Users] DROP COLUMN [Notes];

GO

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'Type');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [Users] DROP COLUMN [Type];

GO

CREATE TABLE [Outcomes] (
    [Id] int NOT NULL IDENTITY,
    [CreatedDate] datetime2 NOT NULL,
    [LastModifiedDate] datetime2 NOT NULL,
    [QuizId] int NOT NULL,
    [ResultDesc] nvarchar(max) NOT NULL,
    [UserId] int NOT NULL,
    CONSTRAINT [PK_Outcomes] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Outcomes_Quizzes_QuizId] FOREIGN KEY ([QuizId]) REFERENCES [Quizzes] ([Id]) ON DELETE CASCADE
);

GO

CREATE INDEX [IX_Outcomes_QuizId] ON [Outcomes] ([QuizId]);

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180612005306_Add Outcomes', N'2.0.2-rtm-10011');

GO

