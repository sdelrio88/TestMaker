import { Pipe, PipeTransform } from '@angular/core';
@Pipe({
    name: 'filter'
})
export class FilterPipe implements PipeTransform {
    transform(items: Question[], answer: Answer): Question[] {
        if (!items) return [];
        if (!answer) return items;

        var answerId = answer.QuestionId;
        return items.filter(it => {
            return it.Id == answerId;
        });
    }
}
