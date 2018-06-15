using Microsoft.EntityFrameworkCore.Migrations;
using System;
using System.Collections.Generic;

namespace TestMakerFreeWebApp.Data.Migrations
{
    public partial class ChangeUserIdToUserName : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {

            migrationBuilder.RenameColumn(
                name: "UserId",
                table: "Outcomes",
                newName: "UserName");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "UserName",
                table: "Outcomes",
                newName: "UserId");
        }
    }
}
