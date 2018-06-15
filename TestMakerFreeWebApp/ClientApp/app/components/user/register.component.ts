import { Component, Inject } from "@angular/core";
import { FormGroup, FormControl, FormBuilder, Validators } from '@angular/forms';
import { Router } from "@angular/router";
import { HttpClient } from "@angular/common/http";
import { AuthService } from "../../services/auth.service";

@Component({
    selector: "register",
    templateUrl: "./register.component.html",
    styleUrls: ['./register.component.css']
})

export class RegisterComponent {
    title: string;
    form: FormGroup;

    constructor(private router: Router,
        private fb: FormBuilder,
        private http: HttpClient,
        private authService: AuthService,
        @Inject('BASE_URL') private baseUrl: string) {

        this.title = "New User Registration";

        // initialize the form
        this.createForm();

    }

    createForm() {
        this.form = this.fb.group({
            Username: ['', Validators.required ],
            Email: ['',
                [Validators.required,
                Validators.email]
            ],
            Password: ['', [Validators.required, Validators.minLength(7), Validators.pattern("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{7,}$")]],
            PasswordConfirm: ['', [Validators.required, Validators.minLength(7), Validators.pattern("^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{7,}$")]],
            DisplayName: ['', Validators.required]
        }, {
                validator: this.passwordConfirmValidator
            });
    }

    onSubmit() {
        // build a temporary user object from form values
        var tempUser = <User>{};
        tempUser.UserName = this.form.value.Username;
        tempUser.Email = this.form.value.Email;
        tempUser.Password = this.form.value.Password;
        tempUser.DisplayName = this.form.value.DisplayName;

        var url = this.baseUrl + "api/user";

        this.http
            .put<User>(url, tempUser)
            .subscribe(res => {
                if (res) {
                    var v = res;
                    console.log("User " + v.UserName + " has been created.");
                }
                else {
                    // registration failed
                    this.form.setErrors({
                        "register": "User registration failed."
                    });
                }
            }, error => {
                console.log(error);
            }, () => {
                this.authService.login(tempUser.UserName, tempUser.Password).subscribe(() => {
                    this.router.navigate(['/home']);
                });
            });
    }

    onBack() {
        this.router.navigate(["home"]);
    }

    // custom validator to compare 
    //   the Password and passwordConfirm values.
    passwordConfirmValidator(control: FormControl): any {

        // retrieve the two Controls
        let p = control.root.get('Password');
        let pc = control.root.get('PasswordConfirm');

        if (p && pc) {
            if (p.value !== pc.value) {
                pc.setErrors(
                    { "PasswordMismatch": true }
                );
            }
            else {
                pc.setErrors(null);
            }
        }
        return null;
    }

    // retrieve a FormControl
    getFormControl(name: string) {
        return this.form.get(name);
    }

    // returns TRUE if the FormControl is valid
    isValid(name: string) {
        var e = this.getFormControl(name);
        return e && e.valid;
    }

    // returns TRUE if the FormControl has been changed
    isChanged(name: string) {
        var e = this.getFormControl(name);
        return e && (e.dirty || e.touched);
    }

    // returns TRUE if the FormControl is invalid after user changes
    hasError(name: string) {
        var e = this.getFormControl(name);
        return e && (e.dirty || e.touched) && !e.valid;
    }
}
