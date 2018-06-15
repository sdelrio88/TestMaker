import { Component, Inject} from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { HttpClient } from "@angular/common/http";
import { AuthService } from '../../services/auth.service';


@Component({
    selector: "quiz",
    templateUrl: './quiz.component.html',
    styleUrls: ['./quiz.component.css'],
})

export class QuizComponent {
    quiz: Quiz;
    currentUser: any;
    currentUserName: string;
    currentUserId: string;
    outcomes: Outcome[] = [];
    canEdit: boolean = false;

    constructor(private activatedRoute: ActivatedRoute,
                private router: Router,
                private http: HttpClient,
                public auth: AuthService,
                @Inject('BASE_URL') private baseUrl: string) {

        // create an empty object from the Quiz interface
        this.quiz = <Quiz>{};


        // get the current user's name from localStorage token
        this.currentUser = auth.getAuth();
        if (this.currentUser != null) {
            this.currentUserName = this.currentUser.userName;
            this.currentUserId = this.currentUser.userId;
        }

        var id = +this.activatedRoute.snapshot.params["id"];
        if (id) {
            var url = baseUrl + "api/quiz/" + id;

            this.http.get<Quiz>(url).subscribe(result => {
                this.quiz = result;  //store the quiz

                if (this.currentUserId == this.quiz.UserId) {
                    this.canEdit = true;   // User can only edit this quiz if they are the owner of this quiz
                }

            // get all outcomes for this quiz (for STATS page)
            var url = baseUrl + "api/outcome/All/" + id;
            this.http.get<Outcome[]>(url).subscribe(result => {
                 this.outcomes = result;
            });
            }, error => console.error(error));
        }
        else {
            console.log("Invalid id: routing back to home...");
            this.router.navigate(["home"]);
        }
    }

    onEdit() {
        this.router.navigate(["quiz/edit", this.quiz.Id]);
    }

    onDelete() {
        if (confirm("Do you really want to delete this quiz?")) {
            var url = this.baseUrl + 'api/quiz/' + this.quiz.Id;
            this.http
                .delete(url)
                .subscribe(res => {
                    this.router.navigate(["home"]);
                }, error => console.error(error));
        }
    }
}