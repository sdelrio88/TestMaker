import { Component, Inject, OnInit, OnDestroy} from "@angular/core";
import { ActivatedRoute, Router } from "@angular/router";
import { HttpClient } from "@angular/common/http";
import { AuthService } from '../../services/auth.service';
import { NgForm } from '@angular/forms';
import { Subject, Subscription } from "rxjs";



@Component({
    selector: "quiz-take",
    templateUrl: './quiz-take.component.html',
    styleUrls: ['./quiz-take.component.css']
})

export class QuizTakeComponent implements OnInit, OnDestroy{
    quiz: Quiz;
    questionsArray: any[] = [];
    questions: Question[] = [];
    answers: any[] = [];
    results: Result[] = [];
    answersLoaded: number = 0;
    answersSubject = new Subject<number>();
    answersSubscription: Subscription;
    currentUserName: string;
    quizId: number;
    quizSubmitted: boolean = false;
    userOutcome: string;

    constructor(private activatedRoute: ActivatedRoute,
        private router: Router,
        private http: HttpClient,
        public auth: AuthService,
        @Inject('BASE_URL') private baseUrl: string) {

        
        this.quizId = +this.activatedRoute.snapshot.params["id"];  // Grabs quizID of type int
        this.currentUserName = this.activatedRoute.snapshot.params["id2"];  // Grabs userName of type string
  
    }

    ngOnInit() {
        this.answersSubscription = this.answersSubject.subscribe(answersStatus => {
            this.answersLoaded = answersStatus;  // a number count
        if (this.answersLoaded >= this.questions.length) {
            this.createQuestionsArray();  // At this point, we've loaded all questions and answers. Store them.
            };
        });

        if (this.quizId) {
            var url = this.baseUrl + "api/quiz/" + this.quizId;

            this.http.get<Quiz>(url).subscribe(result => {
                this.quiz = result;

                this.loadQuestions();
            }, error => console.error(error));
        }
        else {
            console.log("Invalid id: routing back to home...");
            this.router.navigate(["home"]);
        }
    }

    ngOnDestroy() {
        this.answersSubscription.unsubscribe();
    }


    loadQuestions() {
        var url = this.baseUrl + "api/question/All/" + this.quiz.Id;
        this.http.get<Question[]>(url).subscribe(result => {
            this.questions = result;
            this.loadAnswers();
        }, error => console.error(error));
    }

    loadAnswers() {
        for (var i = 0; i < this.questions.length; i++) {
            var url = this.baseUrl + "api/answer/All/" + this.questions[i].Id;
            this.http.get<Answer[]>(url).subscribe(result => {
                this.answers.push(result);
            }, error => console.error(error),
            () => { this.answersSubject.next(this.answersLoaded + 1); });
        } 
    }

    loadResults() {
        var url = this.baseUrl + "api/result/All/" + this.quiz.Id;
        this.http.get<Result[]>(url).subscribe(result => {
            this.results = result;
        }, error => console.error(error));
    }

    // This function creates a new array of objects that maps the questions with their respective answers.
    // This is necessary because answers are subscribed via observable, therefore they are returned in any order.
    createQuestionsArray() {
        for (var i = 0; i < this.questions.length; i++) {
            for (var j = 0; j < this.questions.length; j++) {
                if (this.questions[i].Id == this.answers[j][0].QuestionId) {
                    this.questionsArray[i] = {
                        questionId: this.questions[i].Id,
                        questionText: this.questions[i].Text,
                        answers: this.answers[j]
                    };
                }
            }
        }
    }

    questionsAndAnswersExist() {
        if (this.questions.length > 0 && this.answers.length > 0) {
            if (this.answersLoaded >= this.questions.length) {
                return true;
            }
        }
        return false;
    }

    onBack() {
        this.router.navigate(["quiz/", this.quiz.Id])
    }

    onSubmit(form: NgForm) {
        var scoreTotal = 0;
        for (var value in form.value) {
            scoreTotal += form.value[value];
        }

        // calculate and store the result, quizId, and userId into DB
        var url = this.baseUrl + "api/result/All/" + this.quiz.Id;
        this.http.get<Result[]>(url).subscribe(result => {
            this.results = result;
        }, error => console.error(error),
            () => {
              // Calculate the user's score to store in DB
                var scoreAverage = Math.round(scoreTotal / this.results.length);

                var url = this.baseUrl + "api/outcome";
              // build a temporary outcome object
                var tempOutcome = <Outcome>{};
                tempOutcome.QuizId = this.quizId;
                tempOutcome.UserName = this.currentUserName;
                tempOutcome.ResultDesc = this.results[scoreAverage - 1].Text;

              // Store the outcome
                this.http.post<Outcome>(url, tempOutcome).subscribe(result => {
                    this.userOutcome = tempOutcome.ResultDesc;
                   this.quizSubmitted = true;
                })
           });
           
    }
    
}