IF OBJECT_ID(N'__EFMigrationsHistory') IS NULL
BEGIN
    CREATE TABLE [__EFMigrationsHistory] (
        [MigrationId] nvarchar(150) NOT NULL,
        [ProductVersion] nvarchar(32) NOT NULL,
        CONSTRAINT [PK___EFMigrationsHistory] PRIMARY KEY ([MigrationId])
    );
END;

GO

CREATE TABLE [Users] (
    [Id] nvarchar(450) NOT NULL,
    [CreatedDate] datetime2 NOT NULL,
    [DisplayName] nvarchar(max) NULL,
    [Email] nvarchar(max) NOT NULL,
    [Flags] int NOT NULL,
    [LastModifiedDate] datetime2 NOT NULL,
    [Notes] nvarchar(max) NULL,
    [Type] int NOT NULL,
    [UserName] nvarchar(128) NOT NULL,
    CONSTRAINT [PK_Users] PRIMARY KEY ([Id])
);

GO

CREATE TABLE [Quizzes] (
    [Id] int NOT NULL IDENTITY,
    [CreatedDate] datetime2 NOT NULL,
    [Description] nvarchar(max) NULL,
    [Flags] int NOT NULL,
    [LastModifiedDate] datetime2 NOT NULL,
    [Notes] nvarchar(max) NULL,
    [Text] nvarchar(max) NULL,
    [Title] nvarchar(max) NOT NULL,
    [Type] int NOT NULL,
    [UserId] nvarchar(450) NOT NULL,
    [ViewCount] int NOT NULL,
    CONSTRAINT [PK_Quizzes] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Quizzes_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [Questions] (
    [Id] int NOT NULL IDENTITY,
    [CreatedDate] datetime2 NOT NULL,
    [Flags] int NOT NULL,
    [LastModifiedDate] datetime2 NOT NULL,
    [Notes] nvarchar(max) NULL,
    [QuizId] int NOT NULL,
    [Text] nvarchar(max) NOT NULL,
    [Type] int NOT NULL,
    CONSTRAINT [PK_Questions] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Questions_Quizzes_QuizId] FOREIGN KEY ([QuizId]) REFERENCES [Quizzes] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [Results] (
    [Id] int NOT NULL IDENTITY,
    [CreatedDate] datetime2 NOT NULL,
    [Flags] int NOT NULL,
    [LastModifiedDate] datetime2 NOT NULL,
    [MaxValue] int NULL,
    [MinValue] int NULL,
    [Notes] nvarchar(max) NULL,
    [QuizId] int NOT NULL,
    [Text] nvarchar(max) NOT NULL,
    [Type] int NOT NULL,
    CONSTRAINT [PK_Results] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Results_Quizzes_QuizId] FOREIGN KEY ([QuizId]) REFERENCES [Quizzes] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [Answers] (
    [Id] int NOT NULL IDENTITY,
    [CreatedDate] datetime2 NOT NULL,
    [Flags] int NOT NULL,
    [LastModifiedDate] datetime2 NOT NULL,
    [Notes] nvarchar(max) NULL,
    [QuestionId] int NOT NULL,
    [Text] nvarchar(max) NOT NULL,
    [Type] int NOT NULL,
    [Value] int NOT NULL,
    CONSTRAINT [PK_Answers] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Answers_Questions_QuestionId] FOREIGN KEY ([QuestionId]) REFERENCES [Questions] ([Id]) ON DELETE CASCADE
);

GO

CREATE INDEX [IX_Answers_QuestionId] ON [Answers] ([QuestionId]);

GO

CREATE INDEX [IX_Questions_QuizId] ON [Questions] ([QuizId]);

GO

CREATE INDEX [IX_Quizzes_UserId] ON [Quizzes] ([UserId]);

GO

CREATE INDEX [IX_Results_QuizId] ON [Results] ([QuizId]);

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180503022256_Initial', N'2.0.2-rtm-10011');

GO

DECLARE @var0 sysname;
SELECT @var0 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'UserName');
IF @var0 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var0 + '];');
ALTER TABLE [Users] ALTER COLUMN [UserName] nvarchar(256) NULL;

GO

DECLARE @var1 sysname;
SELECT @var1 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'Email');
IF @var1 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var1 + '];');
ALTER TABLE [Users] ALTER COLUMN [Email] nvarchar(256) NULL;

GO

ALTER TABLE [Users] ADD [AccessFailedCount] int NOT NULL DEFAULT 0;

GO

ALTER TABLE [Users] ADD [ConcurrencyStamp] nvarchar(max) NULL;

GO

ALTER TABLE [Users] ADD [EmailConfirmed] bit NOT NULL DEFAULT 0;

GO

ALTER TABLE [Users] ADD [LockoutEnabled] bit NOT NULL DEFAULT 0;

GO

ALTER TABLE [Users] ADD [LockoutEnd] datetimeoffset NULL;

GO

ALTER TABLE [Users] ADD [NormalizedEmail] nvarchar(256) NULL;

GO

ALTER TABLE [Users] ADD [NormalizedUserName] nvarchar(256) NULL;

GO

ALTER TABLE [Users] ADD [PasswordHash] nvarchar(max) NULL;

GO

ALTER TABLE [Users] ADD [PhoneNumber] nvarchar(max) NULL;

GO

ALTER TABLE [Users] ADD [PhoneNumberConfirmed] bit NOT NULL DEFAULT 0;

GO

ALTER TABLE [Users] ADD [SecurityStamp] nvarchar(max) NULL;

GO

ALTER TABLE [Users] ADD [TwoFactorEnabled] bit NOT NULL DEFAULT 0;

GO

CREATE TABLE [AspNetRoles] (
    [Id] nvarchar(450) NOT NULL,
    [ConcurrencyStamp] nvarchar(max) NULL,
    [Name] nvarchar(256) NULL,
    [NormalizedName] nvarchar(256) NULL,
    CONSTRAINT [PK_AspNetRoles] PRIMARY KEY ([Id])
);

GO

CREATE TABLE [AspNetUserClaims] (
    [Id] int NOT NULL IDENTITY,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    [UserId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetUserClaims_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [AspNetUserLogins] (
    [LoginProvider] nvarchar(450) NOT NULL,
    [ProviderKey] nvarchar(450) NOT NULL,
    [ProviderDisplayName] nvarchar(max) NULL,
    [UserId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserLogins] PRIMARY KEY ([LoginProvider], [ProviderKey]),
    CONSTRAINT [FK_AspNetUserLogins_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [AspNetUserTokens] (
    [UserId] nvarchar(450) NOT NULL,
    [LoginProvider] nvarchar(450) NOT NULL,
    [Name] nvarchar(450) NOT NULL,
    [Value] nvarchar(max) NULL,
    CONSTRAINT [PK_AspNetUserTokens] PRIMARY KEY ([UserId], [LoginProvider], [Name]),
    CONSTRAINT [FK_AspNetUserTokens_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [AspNetRoleClaims] (
    [Id] int NOT NULL IDENTITY,
    [ClaimType] nvarchar(max) NULL,
    [ClaimValue] nvarchar(max) NULL,
    [RoleId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetRoleClaims] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_AspNetRoleClaims_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE
);

GO

CREATE TABLE [AspNetUserRoles] (
    [UserId] nvarchar(450) NOT NULL,
    [RoleId] nvarchar(450) NOT NULL,
    CONSTRAINT [PK_AspNetUserRoles] PRIMARY KEY ([UserId], [RoleId]),
    CONSTRAINT [FK_AspNetUserRoles_AspNetRoles_RoleId] FOREIGN KEY ([RoleId]) REFERENCES [AspNetRoles] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_AspNetUserRoles_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);

GO

CREATE INDEX [EmailIndex] ON [Users] ([NormalizedEmail]);

GO

CREATE UNIQUE INDEX [UserNameIndex] ON [Users] ([NormalizedUserName]) WHERE [NormalizedUserName] IS NOT NULL;

GO

CREATE INDEX [IX_AspNetRoleClaims_RoleId] ON [AspNetRoleClaims] ([RoleId]);

GO

CREATE UNIQUE INDEX [RoleNameIndex] ON [AspNetRoles] ([NormalizedName]) WHERE [NormalizedName] IS NOT NULL;

GO

CREATE INDEX [IX_AspNetUserClaims_UserId] ON [AspNetUserClaims] ([UserId]);

GO

CREATE INDEX [IX_AspNetUserLogins_UserId] ON [AspNetUserLogins] ([UserId]);

GO

CREATE INDEX [IX_AspNetUserRoles_RoleId] ON [AspNetUserRoles] ([RoleId]);

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180514190509_Identity', N'2.0.2-rtm-10011');

GO

CREATE TABLE [Tokens] (
    [Id] int NOT NULL IDENTITY,
    [ClientId] nvarchar(max) NOT NULL,
    [CreatedDate] datetime2 NOT NULL,
    [LastModifiedDate] datetime2 NOT NULL,
    [Type] int NOT NULL,
    [UserId] nvarchar(450) NOT NULL,
    [Value] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_Tokens] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Tokens_Users_UserId] FOREIGN KEY ([UserId]) REFERENCES [Users] ([Id]) ON DELETE CASCADE
);

GO

CREATE INDEX [IX_Tokens_UserId] ON [Tokens] ([UserId]);

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180515192738_RefreshTokens', N'2.0.2-rtm-10011');

GO

DECLARE @var2 sysname;
SELECT @var2 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'Flags');
IF @var2 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var2 + '];');
ALTER TABLE [Users] DROP COLUMN [Flags];

GO

DECLARE @var3 sysname;
SELECT @var3 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'Notes');
IF @var3 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var3 + '];');
ALTER TABLE [Users] DROP COLUMN [Notes];

GO

DECLARE @var4 sysname;
SELECT @var4 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Users') AND [c].[name] = N'Type');
IF @var4 IS NOT NULL EXEC(N'ALTER TABLE [Users] DROP CONSTRAINT [' + @var4 + '];');
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

DECLARE @var5 sysname;
SELECT @var5 = [d].[name]
FROM [sys].[default_constraints] [d]
INNER JOIN [sys].[columns] [c] ON [d].[parent_column_id] = [c].[column_id] AND [d].[parent_object_id] = [c].[object_id]
WHERE ([d].[parent_object_id] = OBJECT_ID(N'Outcomes') AND [c].[name] = N'UserId');
IF @var5 IS NOT NULL EXEC(N'ALTER TABLE [Outcomes] DROP CONSTRAINT [' + @var5 + '];');
ALTER TABLE [Outcomes] ALTER COLUMN [UserId] nvarchar(max) NOT NULL;

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180612171431_ChangeOutcomeUserIdToString', N'2.0.2-rtm-10011');

GO

EXEC sp_rename N'Outcomes.UserId', N'UserName', N'COLUMN';

GO

INSERT INTO [__EFMigrationsHistory] ([MigrationId], [ProductVersion])
VALUES (N'20180612201149_ChangeUserIdToUserName', N'2.0.2-rtm-10011');

GO

