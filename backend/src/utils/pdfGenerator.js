/**
 * Utility to trigger PDF generation and printing.
 * We recommend `react-to-print` for printing specific components from React.
 * 
 * If you need to generate and download a PDF directly without bringing up the print dialog,
 * you can use libraries like `html2pdf.js` or `jspdf`.
 */

export const triggerPrint = () => {
  window.print();
};

export const formatCurrency = (amount) => {
  return new Intl.NumberFormat('en-PK', {
    style: 'currency',
    currency: 'PKR',
    minimumFractionDigits: 2
  }).format(amount).replace('PKR', 'Rs. ');
};
