/* ==========================================
   JS: Маска для полей дат (дд.мм.гггг)
   ========================================== */

document.addEventListener('DOMContentLoaded', function () {
    setTimeout(function () {
        var dateFields = ['start_date', 'end_date'];

        dateFields.forEach(function (fieldName) {
            var input = document.querySelector('input[name="' + fieldName + '"]');

            if (input) {
                input.setAttribute('placeholder', 'дд.мм.гггг');
                input.setAttribute('maxlength', '10');
                input.setAttribute('inputmode', 'numeric');
                input.setAttribute('autocomplete', 'off');

                input.addEventListener('input', function () {
                    var v = this.value.replace(/\D/g, '');
                    if (v.length > 8) v = v.slice(0, 8);

                    var result = '';
                    if (v.length > 0) result = v.slice(0, 2);
                    if (v.length > 2) result += '.' + v.slice(2, 4);
                    if (v.length > 4) result += '.' + v.slice(4, 8);

                    this.value = result;
                });

                input.addEventListener('blur', function () {
                    var v = this.value.replace(/\D/g, '');
                    if (v.length === 8) {
                        this.value = v.slice(0, 2) + '.' + v.slice(2, 4) + '.' + v.slice(4, 8);
                    }
                });
            }
        });
    }, 500);
});