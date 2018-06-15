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

