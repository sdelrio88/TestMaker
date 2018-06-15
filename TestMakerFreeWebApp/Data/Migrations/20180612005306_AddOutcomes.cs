using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;

namespace TestMakerFreeWebApp.Data.Migrations
{
    public partial class AddOutcomes : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Flags",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Notes",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "Type",
                table: "Users");

            migrationBuilder.CreateTable(
                name: "Outcomes",
                columns: table => new
                {
                    Id = table.Column<int>(nullable: false)
                        .Annotation("SqlServer:ValueGenerationStrategy", SqlServerValueGenerationStrategy.IdentityColumn),
                    CreatedDate = table.Column<DateTime>(nullable: false),
                    LastModifiedDate = table.Column<DateTime>(nullable: false),
                    QuizId = table.Column<int>(nullable: false),
                    ResultDesc = table.Column<string>(nullable: false),
                    UserId = table.Column<int>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Outcomes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Outcomes_Quizzes_QuizId",
                        column: x => x.QuizId,
                        principalTable: "Quizzes",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Outcomes_QuizId",
                table: "Outcomes",
                column: "QuizId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Outcomes");

            migrationBuilder.AddColumn<int>(
                name: "Flags",
                table: "Users",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<string>(
                name: "Notes",
                table: "Users",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Type",
                table: "Users",
                nullable: false,
                defaultValue: 0);
        }
    }
}
